function [nodesScenarioTwo, eventsScenarioTwo] = helperBLEMeshSimulateScenarioTwo(nodePositions, ...
    simulationTime, highlightTransmissions, sourceDestinationPairs, ttl, relayNodes, failedNodes)
%helperBLEMeshSimulateScenarioTwo Run Bluetooth mesh network simulation for
%scenario two stated in BLEMeshNetworkFloodingExample
%
%   [NODESSCENARIOTWO, EVENTSSCENARIOTWO] =
%   helperBLEMeshSimulateScenarioTwo(NODEPOSITIONS, SIMULATIONTIME,
%   HIGHLIGHTTRANSMISSIONS, SOURCEDESTINATIONPAIRS, TTL, RELAYNODES,
%   FAILEDNODE) Creates and configures Bluetooth mesh nodes, and runs the
%   simulation.
%
%   NODESSCENARIOTWO is an array of objects of type bluetoothLENode.
%
%   EVENTSSCENARIOTWO is an object of type helperBLEMeshEventCallback.
%
%   NODEPOSITIONS is a n-by-2 array containing [x, y] positions of the
%   node.
%
%   SIMULATIONTIME is a scalar double value.
%
%   HIGHLIGHTTRANSMISSIONS is a Boolean flag. A true value indicates that
%   the packet flow visualization in the mesh network plot is enabled.
%
%   SOURCEDESTINATIONPAIRS is an n-by-2 array containing the source and
%   destination pairs used in simulating scenario two.
%
%   TTL indicates time to live (TTL) value used in the message publication
%   between source and destination pair.
%
%   RELAYNODES, FAILEDNODES are integer vectors.

%   Copyright 2021-2022 The MathWorks, Inc.

% Number of nodes in the network
numNodes = size(nodePositions, 1);
% Initialize the wireless network simulator by using the init object
% function of wirelessNetworkSimulator class.
networkSimulator = wirelessNetworkSimulator.init();
% Initialize array to store Bluetooth mesh nodes
nodesScenarioTwo = bluetoothLENode.empty(0, numNodes);

% Create Bluetooth mesh network for scenario two
for nodeIndex = 1:numNodes
    % Create and configure Bluetooth mesh profile
    meshCfg = bluetoothMeshProfileConfig(ElementAddress=dec2hex(nodeIndex, 4), ...
        NetworkTransmissions=2, NetworkTransmitInterval=randi([1 3])*10e-3);

    % For the configured relayNodes, enable Relay feature
    if any(nodeIndex==relayNodes)
        meshCfg.Relay = true;
        meshCfg.RelayRetransmissions = 3;
        meshCfg.RelayRetransmitInterval = randi([1 3])*10e-3;
    end

    % Create and configure Bluetooth mesh node
    nodesScenarioTwo(nodeIndex) = bluetoothLENode("broadcaster-observer", MeshConfig=meshCfg, ...
        Position=[nodePositions(nodeIndex,:) 0], Name="Node"+num2str(nodeIndex), ...
        ReceiverRange=25, AdvertisingInterval=20e-3, ScanInterval=30e-3);
end

% Add traffic at source nodes
for srcIdx = 1:numel(sourceDestinationPairs)/2
    traffic = networkTrafficOnOff(DataRate=1, PacketSize=15, GeneratePacket=true, ...
        OnTime=simulationTime*0.3, OffTime=simulationTime*0.7);

    addTrafficSource(nodesScenarioTwo(sourceDestinationPairs(srcIdx, 1)), traffic, ...                        % Traffic object
        SourceAddress=nodesScenarioTwo(sourceDestinationPairs(srcIdx, 1)).MeshConfig.ElementAddress, ...      % Source element address
        DestinationAddress=nodesScenarioTwo(sourceDestinationPairs(srcIdx, 2)).MeshConfig.ElementAddress, ... % Destination element address
        TTL=ttl);
end

% Object to visualize mesh network
plotScenarioTwo = helperBLEMeshVisualizeNetwork(NumberOfNodes=numNodes, ...
    NodePositionType="UserInput", Positions=nodePositions, ReceiverRange=25, ...
    SimulationTime=simulationTime, SourceDestinationPairs=sourceDestinationPairs, ...
    Title="Scenario two: Bluetooth Mesh Flooding");
% Object to handle visualization callbacks
eventsScenarioTwo = helperBLEMeshEventCallback(nodesScenarioTwo, plotScenarioTwo, ...
    HighlightTransmissions=highlightTransmissions, FailedNodeIndices=failedNodes);

% Remove failed nodes from the network
for idx = 1:numel(failedNodes)
    nodesScenarioTwo(failedNodes(idx)) = [];
end

% Add nodes to the wireless network simulator
addNodes(networkSimulator, nodesScenarioTwo);

% Run the network simulation for the specified time
run(networkSimulator, simulationTime);
end
