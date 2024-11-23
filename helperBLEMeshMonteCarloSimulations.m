% helperBLEMeshMonteCarloSimulations Helper script for running Monte Carlo
% simulations for a Bluetooth mesh network to observe the critical relays
% for communication between the source and destination nodes.

% Copyright 2019-2022 The MathWorks, Inc.

% Number of nodes in the mesh network
totalNodes = 21;

% Load node positions
load('bleMeshNetworkNodePositions.mat');

% Simulation time in seconds
simulationTime = 0.6;

% Source and destination pair
srcDstPair = [1 10];

% TTL value for messages originated from the source
ttl = 10;

% Relay nodes
relayNodes = [3 6 7 8 9 12 13 14 15 17];

% Initialize
numSeeds = 1e3;
relayDropIdx = 1;
criticalRelaysIdx = 1;
successfulSims = 0;
totalSims = numSeeds*numel(relayNodes);
criticalRelays = zeros(1, numSeeds);

% Run Monte-Carlo simulations
for idx = 1:numSeeds
    rng(idx,'twister');
    selectedRelays = relayNodes;
    % Run simulation by disabling the relay feature for random nodes
    for simIdx = 1:numel(selectedRelays)
        % Initialize the wireless network simulator by using the init
        % object function of wirelessNetworkSimulator class
        networkSimulator = wirelessNetworkSimulator.init();

        % Select relay nodes for the simulation
        relayDropIdx = randi([1 numel(selectedRelays)]);
        droppedRelay = selectedRelays(relayDropIdx);
        selectedRelays = setdiff(selectedRelays, droppedRelay);

        % Create Bluetooth mesh network
        bleMeshNodes = bluetoothLENode.empty(0, totalNodes);
        for nodeIdx = 1:totalNodes
            meshCfg = bluetoothMeshProfileConfig(ElementAddress=dec2hex(nodeIdx, 4));
            if any(nodeIdx==selectedRelays)
                meshCfg.Relay = true;
                meshCfg.RelayRetransmitInterval = randi([1 3])*10e-3;
            end
            bleMeshNodes(nodeIdx) = bluetoothLENode('broadcaster-observer', MeshConfig=meshCfg, ...
                Position=[bleMeshNetworkNodePositions(nodeIdx,:) 0], ReceiverRange=25, ...
                AdvertisingInterval=20e-3, ScanInterval=30e-3);
        end
        
        % Add traffic source
        srcNode = bleMeshNodes(srcDstPair(1)); % Node1
        dstNode = bleMeshNodes(srcDstPair(2)); % Node10
        srcNode.MeshConfig.NetworkTransmissions = 3;
        srcNode.MeshConfig.NetworkTransmitInterval = randi([1 3])*10e-3;
        traffic = networkTrafficOnOff(DataRate=1, PacketSize=15, ...
            OnTime=0.3, OffTime=0.3, GeneratePacket=true);
        addTrafficSource(srcNode, traffic, ...
            SourceAddress=srcNode.MeshConfig.ElementAddress, ...
            DestinationAddress=dstNode.MeshConfig.ElementAddress, ...
            TTL=ttl);

        % Run the simulation
        addNodes(networkSimulator, bleMeshNodes);
        run(networkSimulator, simulationTime);

        % Calculate PDR
        srcStats = srcNode.statistics;
        dstStats = dstNode.statistics;
        PDR = dstStats.App.ReceivedPackets/srcStats.App.TransmittedPackets;

        % Run these simulations until there is packet exchange between
        % source and destination (PDR > 0). If not (PDR == 0) mark the
        % dropped relay node as a critical relay node
        if PDR == 0
            criticalRelays(criticalRelaysIdx) = droppedRelay;
            criticalRelaysIdx = criticalRelaysIdx+1;
            break;
        end
    end
end

% Critical relay nodes
uniqueCriticalRelays = unique(criticalRelays);
criticalRelaysInfo = table('Size', [numel(uniqueCriticalRelays), 2], ...
    'VariableTypes', {'double','double'}, 'VariableNames', ...
    {'Relay', 'Probability of failure'});
for idx = 1:numel(uniqueCriticalRelays)
    criticalRelaysInfo{idx, 1} = uniqueCriticalRelays(idx);
    criticalRelaysInfo{idx, 2} = ...
        (nnz(criticalRelays == uniqueCriticalRelays(idx))/numel(criticalRelays))*100;
end
criticalRelaysInfo = sortrows(criticalRelaysInfo, 'Probability of failure', 'descend');

% Critical relays and their importance percentage (probability of failure)
% in having a path between source to destination is stored in variable
% 'criticalRelaysInfo'
if ~isempty(criticalRelaysInfo)
    relayIdx = min(5, size(criticalRelaysInfo, 1));
    disp(['Nodes [' num2str(criticalRelaysInfo{1:relayIdx, 1}') '] are the top ' ...
        num2str(relayIdx) ' critical relays for having communication between Node' num2str(srcDstPair(1)) ...
        ' and Node' num2str(srcDstPair(2)) '.']);
end
