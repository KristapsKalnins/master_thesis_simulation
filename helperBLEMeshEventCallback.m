classdef helperBLEMeshEventCallback < handle
    %helperBLEMeshEventCallback Helper to provide callback functions used
    %for visualization and path derivation in Bluetooth mesh network system
    %level simulations.
    %
    %   MESHCB = helperBLEMeshEventCallback(NODES, NETWORKPLOT) creates an
    %   object having callback functions to invoke the message transmission
    %   visualization and path derivation. The callback functions are added
    %   to the event listeners of Bluetooth LE node.
    %
    %   NODES is an array of objects of type bluetoothLENode.
    %
    %   NETWORKPLOT is the network visualization object of type
    %   helperBLEMeshVisualizeNetwork.
    %
    %   helperBLEMeshEventCallback properties:
    %
    %   HighlightTransmissions - Highlight packet transmissions in the mesh
    %                            network visualization
    %   NetworkPlot            - Network visualization object
    %   Nodes                  - List of mesh nodes (object of type bluetoothLENode) in the network
    %   FailedNodeIndices      - List (integer) of ID's for the nodes removed from the network

    %   Copyright 2021-2022 The MathWorks, Inc.

    properties
        %HighlightTransmissions Highlight packet transmissions in the mesh
        %network visualization specified as a boolean value
        HighlightTransmissions = false

        %NetworkPlot Network visualization object specified as an object of
        %type helperBLEMeshVisualizeNetwork
        NetworkPlot

        %Nodes List of mesh nodes (object of type bluetoothLENode) in the
        %network
        Nodes

        %FailedNodeIndices List (integer) of ID's for the nodes removed from
        %the network in a given scenario
        FailedNodeIndices
    end

    properties (Dependent)
        %NumSources Number of data sources in the network
        NumSources
    end

    properties (SetAccess = private)
        %Path Path derived in the simulation for each source and
        %destination pair in the network
        Path
    end

    properties (Access = private)
        %pMessageTuples List of all successful receptions at the node. Used
        %in calculation the path from source node to destination node.
        pMessageTuples

        %pTupleIndex Indexing variable for MessageTuples
        pTupleIndex

        %pPathVisualized Flag indicating whether path is visualized or not
        pPathVisualized

        %pNetworkPacketDropCount Network layer packet drop statistic for
        %each node. Used for storing a successful reception in
        %MessageTuples
        pNetworkPacketDropCount

        %SrcDstPairs List of source and destination node ID pairs in the
        %network
        SrcDstPairs
    end

    methods
        function obj = helperBLEMeshEventCallback(nodes, networkPlot, varargin)
            % Assign name-value pairs
            for idx = 1:2:nargin-2
                obj.(varargin{idx}) = varargin{idx+1};
            end

            % Set the default context used for visualization and path
            % derivation
            obj.Nodes = nodes;
            obj.NetworkPlot = networkPlot;
            obj.SrcDstPairs = obj.NetworkPlot.SourceDestinationPairs;
            obj.Path = cell(1, obj.NumSources);
            obj.pPathVisualized = false(1, obj.NumSources);
            obj.pNetworkPacketDropCount = zeros(1, size(obj.NetworkPlot.Positions, 1));
            obj.pMessageTuples = [];
            obj.pTupleIndex = 1;
            if ~obj.HighlightTransmissions
                obj.NetworkPlot.DisplayProgressBar = false;
            end
            obj.NetworkPlot.NodeType = getNodeTypes(obj);

            for nodeIndex = 1:numel(obj.Nodes)
                % Visualize the path and message flow between the source
                % and destination nodes by adding listener. For more
                % information, see events.
                if obj.HighlightTransmissions
                    addlistener(obj.Nodes(nodeIndex),"PacketTransmissionStarted",...
                        @(source,event) obj.visualizeTransmissions(source,event));
                end
                % Add listener at each node for storing the message receptions
                % in the network
                addlistener(obj.Nodes(nodeIndex),"PacketReceptionEnded", ...
                    @(source,event) obj.storeRx(source,event));
            end

            % Get/Visualize the path between the source and destination by
            % adding a listener at the destination nodes
            for dstIdx = 1:obj.NumSources
                addlistener(obj.Nodes(obj.SrcDstPairs(dstIdx,2)),"MeshAppDataReceived",...
                    @(source,event) obj.showPath(source,event));
            end

            createNetwork(obj.NetworkPlot);        % Visualize mesh network
            updateProgressBar(obj.NetworkPlot, 0); % Simulation start
        end

        function value = get.NumSources(obj)
            value = numel(obj.SrcDstPairs)/2;
        end
 
        function updateFailedNodeState(obj, failedNode)
            %updateFailedNodeState Update the failed node state in the mesh
            %network visualization.

            nodeState = 0; % Node removed from the network
            updateNodeState(obj.NetworkPlot, failedNode, nodeState);
        end

        function visualizeTransmissions(obj, ~, transmittedPacket)
            %visualizeTransmissions Callback function handle passed to
            %addListener in the event notification of Bluetooth LE node.
            %   This function visualizes message transmissions in mesh
            %   network whenever a 'PacketTransmissionStarted' event occurs
            %   in the node.

            % Highlight packet transmissions in the mesh network
            % visualization
            if obj.HighlightTransmissions
                % Store all the message transmissions from the current node
                % to nodes in the vicinity range
                receiverRange = obj.NetworkPlot.ReceiverRange;
                vicinityNodeIDs = helperBLEMeshVisualizeNetwork.vicinityNodes(...
                    transmittedPacket.Data.NodeID, obj.NetworkPlot.Positions, receiverRange);
                messageTx(1:numel(vicinityNodeIDs), :) = transmittedPacket.Data.NodeID;
                messageTx(:, 2) = vicinityNodeIDs';
                messageTx(:, 3) = 1;

                % Visualize transmission
                messageTransmissions(obj.NetworkPlot, messageTx);

                % Update simulation progress
                updateProgressBar(obj.NetworkPlot, transmittedPacket.Data.CurrentTime);
            end
        end

        function storeRx(obj, srcNode, receivedPacket)
            %storeRx Callback function handle passed to addListener in the
            %event notification of Bluetooth LE node.
            %   This function stores the valid message receptions in mesh
            %   network whenever a 'PacketReceptionEnded' event occurs in
            %   the node.

            % Store the current reception between nodes in the network only
            % if the mesh network layer accepted the current packet
            currentStats = srcNode.statistics;
            currentNetworkDropCount = currentStats.Network.DroppedMessages;
            % Current packet is dropped
            if currentNetworkDropCount > obj.pNetworkPacketDropCount(srcNode.ID)
                % Update the packet drop count
                obj.pNetworkPacketDropCount(srcNode.ID) = currentNetworkDropCount;
            else % Current packet is not dropped
                % Store the message transaction
                tuple = [receivedPacket.Data.SourceID receivedPacket.Data.NodeID];
                obj.pMessageTuples(obj.pTupleIndex, :) = tuple;
                obj.pTupleIndex = obj.pTupleIndex + 1;
            end
        end

        function showPath(obj, ~, receivedPacket)
            %showPath Callback function handle passed to addListener in the
            %event notification of Bluetooth LE node.
            %   This function derives and visualizes the path between the
            %   source and the destination node pairs in mesh network
            %   whenever a 'MeshAppDataReceived' event occurs in the node.

            % Get the source and destination pair index
            pairIdx = [];
            for srcIdx = 1:obj.NumSources
                if hex2dec(receivedPacket.Data.SourceAddress) == obj.SrcDstPairs(srcIdx, 1) && ...
                        hex2dec(receivedPacket.Data.DestinationAddress) == obj.SrcDstPairs(srcIdx, 2)
                    pairIdx = srcIdx;
                    break;
                end
            end

            % Derive path for the source and destination pair
            if ~isempty(pairIdx)
                path = obj.getPath(obj.SrcDstPairs(pairIdx, 1), obj.SrcDstPairs(pairIdx, 2));
                obj.Path{pairIdx} = path;
                % Store and visualize path
                if ~isequal(path, -1) && ~obj.pPathVisualized(pairIdx) ...
                        && obj.HighlightTransmissions
                    highlightDstNode(obj.NetworkPlot, obj.SrcDstPairs(pairIdx, 2));
                    showPath(obj.NetworkPlot, path);
                    obj.pPathVisualized(pairIdx) = true;
                end
            end
        end

        function [pdr, path] = meshResults(obj, scenarioStatistics)
            %meshResults Returns network PDR and path between source and
            %destination in the mesh network
            %
            %   [PDR, PATH] = meshPath(OBJ) Returns PDR and list of paths
            %   between the specified source and destination node pairs in
            %   the simulated mesh network.
            %
            %   PDR is a double value indicating the network packet
            %   delivery ratio.
            %
            %   PATH is a table storing list of paths.
            
            % Create a table and store the path results
            path = table('Size', [obj.NumSources, 4], ...
                'VariableTypes', {'double', 'double', 'cell', 'double'}, ...
                'VariableNames', {'Source', 'Destination', 'Path', 'NumberOfHops'});
            for i=1:obj.NumSources
                path{i, 1} = obj.SrcDstPairs(i, 1);
                path{i, 2} = obj.SrcDstPairs(i, 2);
                path{i, 3} = obj.Path(i);
                path{i, 4} = numel(obj.Path{i}) - 1;
            end

            % Calculate PDR
            [totalTransmittedPackets, totalReceivedPackets] = deal(0);
            for srcIdx = 1:numel(obj.SrcDstPairs)/2
                sourceTransmittedPackets = scenarioStatistics([arrayfun(@(statistics) statistics.ID==obj.SrcDstPairs(srcIdx, 1), ...
                    scenarioStatistics, UniformOutput=true)]).App.TransmittedPackets;
                destinationReceivedPackets = scenarioStatistics([arrayfun(@(statistics) statistics.ID==obj.SrcDstPairs(srcIdx, 2), ...
                    scenarioStatistics, UniformOutput=true)]).App.ReceivedPackets;
                totalTransmittedPackets = totalTransmittedPackets + sourceTransmittedPackets;
                totalReceivedPackets = totalReceivedPackets + destinationReceivedPackets;
            end
            pdr = totalReceivedPackets/totalTransmittedPackets;

            % Update simulation progress at the end of the simulation.
            updateProgressBar(obj.NetworkPlot,obj.NetworkPlot.SimulationTime);
        end
    end

    methods(Access = private)
        function path = getPath(obj, sourceNode, destinationNode)
            %meshPath Returns path from source to destination within mesh
            %network
            %   PATH = meshPath(SOURCENODE, DESTINATIONNODE)) returns the
            %   path from source node, SOURCENODE, to destination node,
            %   DESTINATIONNODE, within the Bluetooth mesh network.

            % Get the values of nodes and the message tuples
            meshNodes = obj.Nodes;
            tuples = obj.pMessageTuples;

            % Number of nodes within the Bluetooth mesh network
            totalNodes = numel(meshNodes);

            % Initialize
            path = zeros(1, totalNodes);
            nodeIDs = zeros(1, totalNodes);
            pathIndex = 1;
            hasPath = false;

            % Initialize visited flag for each node
            isVisited = zeros(1, totalNodes);

            % Identifiers for the nodes within the Bluetooth mesh network
            for idx = 1:totalNodes
                nodeIDs(idx) = meshNodes(idx).ID;
            end

            % Push source node "sourceNode" into path
            path(pathIndex) = sourceNode;
            pathIndex = pathIndex + 1;

            % Mark source node "sourceNode" as visited
            isVisited(nodeIDs == sourceNode) = 1;

            while (~hasPath)
                % Fetch top node from the path
                topNode = path(pathIndex-1);

                % Fetch next node to be visited, traverse over all the
                % tuples (each tuple defines a message exchange between the
                % nodes within the Bluetooth mesh network)
                nextUnvisitedNode = -1;
                for idx = 1:numel(tuples)/2
                    % Fetch the next unvisited node from the given node
                    % "topNode"
                    if (tuples(idx, 1) == topNode) && ...
                            ~(isVisited(nodeIDs == tuples(idx, 2)))
                        nextUnvisitedNode = tuples(idx, 2);
                    end
                end

                % All nodes are visited from "topNode"
                if nextUnvisitedNode == -1
                    % Pop "topNode" node from the path
                    path(pathIndex-1) = 0;
                    pathIndex = pathIndex - 1;
                    % Path doesn't exist
                    if pathIndex <= 1
                        path = -1;
                        break;
                    end
                    continue;
                % Path found from "sourceNode" to "destinationNode"
                elseif nextUnvisitedNode == destinationNode
                    hasPath = true;
                end

                % Mark next unvisited node as visited
                isVisited(nodeIDs == nextUnvisitedNode) = 1;

                % Push next unvisited node into path
                path(pathIndex) = nextUnvisitedNode;
                pathIndex = pathIndex + 1;
            end

            % Return identified path between source and destination within
            % the Bluetooth mesh network
            if hasPath
                path = path(1:pathIndex-1);
            end
        end

        function nodeTypes = getNodeTypes(obj)
            % Store types of nodes for visualization
            % 0 - Node removed from the network
            % 1 - Node
            % 2 - Relay node
            % 3 - Friend node
            % 4 - LPN
            nodeTypes = ones(1, numel(obj.Nodes));

            % Fetch type of each node from the specified Nodes array
            for nodeIndex = 1:numel(obj.Nodes)
                if obj.Nodes(nodeIndex).MeshConfig.Relay
                    nodeTypes(nodeIndex) = 2; % Relay node
                elseif obj.Nodes(nodeIndex).MeshConfig.Friend
                    nodeTypes(nodeIndex) = 3; % Friend node
                elseif obj.Nodes(nodeIndex).MeshConfig.LowPower
                    nodeTypes(nodeIndex) = 4; % LPN
                end
                if any(nodeIndex == obj.FailedNodeIndices)
                    nodeTypes(nodeIndex) = 0; % Node removed from the network
                end
            end
        end
    end
end
