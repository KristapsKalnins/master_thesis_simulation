function [paths, pdrs, stats] = run_simulation(node_positions, rec_range, starting_node)
    paths = {};
    pdrs = {};
    stats = {};
    fprintf("Start: %s\n",datestr(now))
    % Load node positions form file
    load(node_positions, "bleMeshNetworkNodePositions");
    % Get an array representing the neighboring nodes for each node
    nodes_and_neighbors = get_neighboring_nodes(bleMeshNetworkNodePositions, rec_range);
    % Get the different waves of provisioners to use for the simulation
    gens = get_provisioner_generations(nodes_and_neighbors, starting_node);
    simTimeVec = nonlinear_vector(16, 1, 0.8, 8.8);
    % Check for necessary packages
    wirelessnetworkSupportPackageCheck;
    for i = 2:(size(gens,2) - 1)
        fprintf("Running simulation %d for gen %d\n", i - 1, i);
        rng((posixtime(datetime('now'))), "twister");
        simulationTime = simTimeVec(i);
        highlightTransmissions = true;

        [nodes, ~, provisionees, ~] = create_subnet(gens, i, bleMeshNetworkNodePositions);


        % Get total number of nodes
        numNodes = size(nodes,1);
        % All nodes in this setup are available for relay
        relayNodes = [2:provisionees(1)-1];
        
        %sourceDestinationPairs = gen_to_source_dest_pair(gens{i}, starting_node);

        sourceDestinationPairs = [provisionees ones(length(provisionees),1)];

        networkSimulator = wirelessNetworkSimulator.init;

        %
        % Creation and configuration of the Mesh Nodes
        %

        nodesScenarioOne = bluetoothLENode.empty(0, numNodes);

        for nodeIndex = 1:numNodes
            % Mention this stuff in the report - the paramaters
            % Create and configure Bluetooth mesh profile by specifying the element
            % address (unique to each node in the network). Set network message
            % repetitions to 2, and network transmit interval as a random value in
            % the range [10, 30] milliseconds.
            meshCfg = bluetoothMeshProfileConfig(ElementAddress=dec2hex(nodeIndex,4),...
                NetworkTransmissions=2,NetworkTransmitInterval=0.1);

            % Enable relay feature of the configured relay nodes. Set relay message
            % repetitions to 3, and relay retransmit interval as a random value in
            % the range [10, 30] milliseconds.
            if any(nodeIndex==relayNodes)
                meshCfg.Relay = true;
                meshCfg.RelayRetransmissions = 3;
                meshCfg.RelayRetransmitInterval = 0.01;
            end


            % Create and configure Bluetooth mesh node by assigning the mesh profile.
            % Set receiver range, advertising interval (seconds) and scan interval (seconds).
            nodesScenarioOne(nodeIndex) = bluetoothLENode("broadcaster-observer",MeshConfig=meshCfg,...
                Position=[nodes(nodeIndex,:) 0],Name="Node"+num2str(nodeIndex),...
                ReceiverRange=rec_range,AdvertisingInterval=20e-3, a=25e-3);

        end


        %
        % Add application traffic to source nodes
        %
        
        for srcIdx = 1:numel(sourceDestinationPairs)/2
            % Set data rate, packet size, on time, and off time based on the
            % simulation time.
            traffic = networkTrafficOnOff(DataRate=1,PacketSize=15,GeneratePacket=true,...
                OnTime=(simulationTime * 0.3),OffTime=(simulationTime * 0.7));


            % Maximum number of hops for a packet is controlled by setting
            % time-to-live (TTL) value
            ttl = 35;

            % Attach application traffic to source
            addTrafficSource(nodesScenarioOne(sourceDestinationPairs(srcIdx,1)),traffic, ...                        % Traffic object
                SourceAddress=nodesScenarioOne(sourceDestinationPairs(srcIdx,1)).MeshConfig.ElementAddress,...      % Source element address
                DestinationAddress=nodesScenarioOne(sourceDestinationPairs(srcIdx,2)).MeshConfig.ElementAddress,... % Destination element address
                TTL=ttl);

            % Test other direction
            %addTrafficSource(nodesScenarioOne(sourceDestinationPairs(srcIdx,2)),traffic, ...                        % Traffic object
            %    SourceAddress=nodesScenarioOne(sourceDestinationPairs(srcIdx,2)).MeshConfig.ElementAddress,...      % Source element address
            %    DestinationAddress=nodesScenarioOne(sourceDestinationPairs(srcIdx,1)).MeshConfig.ElementAddress,... % Destination element address
            %    TTL=ttl);
        end

        %
        % Visualization can be skipped
        %

         plotScenarioOne = helperBLEMeshVisualizeNetwork(NumberOfNodes=numNodes,...
            NodePositionType="UserInput",Positions=nodes,...
            ReceiverRange=rec_range,SimulationTime=simulationTime,...
            SourceDestinationPairs=sourceDestinationPairs,...
            Title="Scenario one: Bluetooth Mesh Flooding");

         eventsScenarioOne = helperBLEMeshEventCallback(nodesScenarioOne,plotScenarioOne,...
            HighlightTransmissions=highlightTransmissions);
        

        addNodes(networkSimulator, nodesScenarioOne);

        % Start the simulation. 
        % This is the command that take a LONG time to complete
        run(networkSimulator, simulationTime);


        % Save statistics for simulation
        for nodeIndex = 1:numel(nodesScenarioOne)
            statisticsScenarioOne(nodeIndex) = statistics(nodesScenarioOne(nodeIndex)); %#ok<*SAGROW>
        end

        [pdrSrenarioOne,pathScenarioOne] = meshResults(eventsScenarioOne,statisticsScenarioOne);

        pdrs{i} = pdrSrenarioOne;

        paths{i} = pathScenarioOne;

        stats{i} = statisticsScenarioOne;

    end
    fprintf("End: %s\n",datestr(now))
end