classdef helperBLEMeshVisualizeNetwork < handle
%helperBLEMeshVisualizeNetwork Creates an object for Bluetooth mesh network
%visualization
%   MESHNETWORK = helperBLEMeshVisualizeNetwork creates a Bluetooth mesh
%   network visualization object with properties and methods related to
%   visualization.
%
%   MESHNETWORK = helperBLEMeshVisualizeNetwork(Name, Value) creates a
%   network visualization object with the specified property Name set to
%   the specified Value. You can specify additional name-value pair
%   arguments in any order as (Name1, Value1, ..., NameN, ValueN).
%
%   helperBLEMeshVisualizeNetwork properties:
%
%   NumberOfNodes          - Number of nodes in the network
%   ReceiverRange          - Node transmission and reception range
%   NodeType               - Type of each node
%   Positions              - List of all node positions
%   NodePositionType       - Type of node position allocation
%   GridInitX              - X coordinate where the grid starts
%   GridInitY              - Y coordinate where the grid starts
%   GridDeltaX             - X space between nodes
%   GridDeltaY             - Y space between nodes
%   GridWidth              - Number of nodes laid out on a line
%   GridLayout             - Type of layout
%   Title                  - Title of the network plot
%   SourceDestinationPairs - Source destination pairs
%   FriendPairs            - Friend and Low Power node pairs
%   SimulationTime         - Simulation time
%   DisplayProgressBar     - Display progress bar

%   Copyright 2019-2023 The MathWorks, Inc.
    
properties
    %NumberOfNodes Number of nodes in the network
    %   Specify number of nodes as an integer. Identifies the total number
    %   of nodes in the network. The default value is 30.
    NumberOfNodes = 30
    
    %ReceiverRange Node transmission and reception range
    %   Specify vicinity range as an integer. Identifies the transmission
    %   and reception range of a node. The default value is 15.
    ReceiverRange = 15
    
    %NodeType Type of each node
    %   Specify node type as a vector of size total number of nodes with 
    %   the following values:
    %   0 - Node off
    %   1 - Node on
    %   2 - Relay on
    %   3 - Friend feature on
    %   4 - Low Power feature on
    %   The default value for all nodes is 1.
    NodeType = ones(1, 30)
    
    %Positions List of all node positions
    %   Specify positions as an array of size (NumberOfNodes, 2) where each
    %   row indicates x, y coordinates of the node.
    Positions
    
    %NodePositionType Type of node position allocation
    %   Specify node position type as one of the 'Grid' | 'UserInput'. The
    %   default value is 'Grid'.
    NodePositionType = 'Grid'
    
    %GridInitX X coordinate where the grid starts
    %   Specify grid initial x as an integer. Identifies x position of the
    %   first node in the grid. The default value is 5.
    GridInitX = 5
    
    %GridInitY Y coordinate where the grid starts.
    %   Specify grid initial y as an integer. Identifies y position of the
    %   first node in the grid. The default value is 5.
    GridInitY = 5
    
    %GridDeltaX X space between nodes
    %   Specify grid delta x as an integer. Identifies distance between x
    %   coordinates of the consecutive nodes. The default value is 10.
    GridDeltaX = 10
    
    %GridDeltaY Y space between nodes
    %   Specify grid delta y as an integer. Identifies distance between y
    %   coordinates of the consecutive nodes. The default value is 10.
    GridDeltaY = 10
    
    %GridWidth Number of nodes laid out on a line
    %   Specify grid width as an integer. Identifies the width of the grid
    %   if row based or height of the grid if column based. The default
    %   value is 5.
    GridWidth = 5
    
    %GridLayout Type of layout
    %   Specify grid layout as one of the 'Row' | 'Column'. Identifies row
    %   or column based grid. The default value is 'Row'.
    GridLayout = 'Row'
    
    %Title Title of the network plot
    %   Specify the title as a char array or string. The default value is
    %   'Network Visualization'.
    Title = 'Network Visualization'
	
	%SourceDestinationPairs Source destination pairs
    %   Specify source-destination pairs as a numeric matrix having each
    %   row corresponding to a source-destination pair.
    SourceDestinationPairs
    
    %FriendPairs Friend and Low Power node pairs
    %   Specify friend pairs as a vector of two elements or a numeric
    %   matrix having each row corresponding to a friend and Low Power node
    %   pair.
    FriendPairs
    
    %SimulationTime Simulation time
    %   Specify the simulation time as an integer indicating the simulation
    %   time in seconds. The default value is 0.
    SimulationTime = 0
    
    %DisplayProgressBar Display progress bar
    %   Specify this property as a scalar logical. A true value indicates
    %   that the progress bar display is enabled for this node. The default
    %   value is true.
    DisplayProgressBar (1, 1) logical = true
end

properties(Constant, Hidden)
    %NodePositionTypeValues Two types of position allocations grid and user
    %input
    NodePositionTypeValues = {'Grid', 'UserInput'}
    
    %GridLayoutValues Row based or column based grid allocation
    GridLayoutValues = {'Row', 'Column'}
    
    %Colors Colors of different paths
    Colors = ["--mw-graphics-colorOrder-5-secondary";"--mw-graphics-colorOrder-11-primary";"--mw-graphics-colorOrder-4-quaternary";"--mw-graphics-colorOrder-6-secondary";"--mw-graphics-colorOrder-12-primary";"--mw-graphics-colorOrder-5-primary""--mw-graphics-colorOrder-7-secondary";"--mw-graphics-colorOrder-13-primary";"--mw-graphics-colorOrder-6-primary""--mw-graphics-colorOrder-8-secondary";"--mw-graphics-colorOrder-14-primary";"--mw-graphics-colorOrder-7-primary""--mw-graphics-colorOrder-9-secondary";"--mw-graphics-colorOrder-15-primary";"--mw-graphics-colorOrder-8-primary""--mw-graphics-colorOrder-10-secondary";"--mw-graphics-colorOrder-16-primary";"--mw-graphics-colorOrder-9-primary""--mw-graphics-colorOrder-11-secondary";"--mw-graphics-colorOrder-17-primary"];


    NodeColors = ["--mw-graphics-colorOrder-9-quaternary"; % Nodes
        "--mw-graphics-colorOrder-10-primary"; % Relay Node
        "--mw-graphics-colorOrder-7-secondary"; % Friend Node
        "--mw-graphics-colorOrder-3-quaternary"; % Low Power Node
        "--mw-graphics-colorNeutral-line-primary"] % Failed Node
end

properties(Access = private)
    %pFigureObj Figure object
    pFigureObj
    
    %pSrcDstPairs Source and destination pairs
    pSrcDstPairs
    
    %pPaths Highlighted paths
    pPaths
    
    %pPathCount Highlighted paths count
    pPathCount = 0
    
    %pTransmissionIDs Transmission IDs
    pTransmissionIDs = [-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1]
    
    %pGraph digraph object
    pGraph
    
    %pProgressInfo Progress bar information
    pProgressInfo
    
    %pPercentageInfo Progress bar percentage
    pPercentageInfo

    %pHighlightNodes List of scatter plot handles for the nodes displayed
    pHighlightNodes = cell(0,0)

    %pEdgeLines List of plot handles for the connections displayed
    pEdgeLines = cell(0,0)

    %pEdges List of connected edges
    pEdges
end

properties(Constant, Hidden)
    %ErrorPacketID Transmission ID of the corrupted packet
    ErrorPacketID = -1
    
    % Progress bar dimensions
    ProgressX = 0.78;
    ProgressY = 0.025;
    ProgressH = 0.02;
    ProgressW = 0.08;

    % Progress bar colors
    ProgressBarBackgroundColor = "--mw-graphics-backgroundColor-axes-primary";
    ProgressBarColor = "--mw-graphics-colorOrder-5-secondary";
end
 
methods
    function obj = helperBLEMeshVisualizeNetwork(varargin)
        % Assign name-value pairs
        for idx = 1:2:nargin
            obj.(varargin{idx}) = varargin{idx+1};
        end
    end
    
    % Set number of nodes
    function set.NumberOfNodes(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', ...
            'integer', '>=', 2, '<=', 1024}, mfilename, 'NumberOfNodes');
        obj.NumberOfNodes = value;
    end
    
    % Set vicinity range
    function set.ReceiverRange(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', ...
            'integer', '>=', 1, '<=', 500}, mfilename, 'ReceiverRange');
        obj.ReceiverRange = value;
    end
    
    % Set node state
    function set.NodeType(obj, value)
        validateNodeType(obj, value);
        obj.NodeType = value;
    end
    
    % Set node positions
    function set.Positions(obj, value)
        validatePositions(obj, value);
        obj.Positions = value;
    end
    
    % Set type of node position allocation
    function set.NodePositionType(obj, value)
        value = validatestring(value, obj.NodePositionTypeValues, ...
            mfilename, 'NodePositionType');
        obj.NodePositionType = value;
    end
    
    % Set grid layout
    function set.GridLayout(obj, value)
        validatestring(value, obj.GridLayoutValues, mfilename, 'GridLayout');
        obj.GridLayout = value;
    end
    
    % Set grid initial x value
    function set.GridInitX(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', ...
            'integer'}, mfilename, 'GridInitX');
        obj.GridInitX = value;
    end
    
    % Set grid initial y value
    function set.GridInitY(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', ...
            'integer'}, mfilename, 'GridInitY');
        obj.GridInitY = value;
    end
    
    % Set grid delta x value
    function set.GridDeltaX(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', ...
            'integer', 'positive'}, mfilename, 'GridDeltaX');
        obj.GridDeltaX = value;
    end
    
    % Set grid delta y value
    function set.GridDeltaY(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', ...
            'integer', 'positive'}, mfilename, 'GridDeltaY');
        obj.GridDeltaY = value;
    end
    
    % Set grid width
    function set.GridWidth(obj, value)
        validateattributes(value, {'numeric'}, {'scalar', ...
            'integer', 'positive'}, mfilename, 'GridWidth');
        obj.GridWidth = value;
    end
    
    % Set Title
    function set.Title(obj, value)
        validateattributes(value, {'string', 'char'}, ...
            {}, mfilename, 'Title');
        obj.Title = value;
    end
    
	% Set SourceDestinationPairs
    function set.SourceDestinationPairs(obj, value)
        validateSrcDstPairs(obj, value);
        obj.SourceDestinationPairs = value;
    end
    
    % Set FriendPairs
    function set.FriendPairs(obj, value)
        validateFriendPairs(obj, value);
        obj.FriendPairs = value;
    end
end

methods
    % Create mesh network with given number of nodes
    function createNetwork(obj)
        % Grid position allocation
        if (obj.NodePositionType == "Grid")
            obj.Positions = obj.gridPositionAllocator();
        else
            if isempty(obj.Positions)
                fprintf('Positions must be given for node position allocation of type ''UserInput''\n');
            end
        end
        
        % Check for network creation
        if isempty(obj.pFigureObj)
            % Get screen resolution and adjust the figure accordingly
            resolution = get(0, 'screensize');
            screenWidth = resolution(3);
            screenHeight = resolution(4);
            figureWidth = screenWidth*0.8;
            figureHeight = screenHeight*0.8;
            
            % Create figure object
            obj.pFigureObj = figure('Name', obj.Title, 'Tag', 'VisualizeNetwork', ...
                'Position', [screenWidth*0.1, screenHeight*0.1, figureWidth, figureHeight], ...
                'NumberTitle', 'off', 'Units', 'Normalized', 'Tag', 'Mesh Network');
            matlab.graphics.internal.themes.figureUseDesktopTheme(obj.pFigureObj);
        end
        
        % Create graph
        obj.plotNetwork();
    end
    
    % Highlight relay transmission based on inputs
    function messageTransmissions(obj, relays)
        hold on

        import matlab.graphics.internal.themes.specifyThemePropertyMappings
        % Check for network creation
        if isempty(obj.pFigureObj)
            fprintf('createNetwork() must be called first.\n');
            return;
        elseif (~isvalid(obj.pFigureObj))
            return;
        end
        
        relayCount = size(relays, 1);
        % Highlight the transmitting node
        for relayIdx = 1 : relayCount
            % Highlight corrupted packets
            if (relays(relayIdx, 3) == obj.ErrorPacketID)
                obj.pHighlightNodes{relays(relayIdx, 1)}.MarkerSize = 100;
                obj.pHighlightNodes{relays(relayIdx, 2)}.MarkerSize = 100;
                if edgecount(obj.pGraph, relays(relayIdx, 1), relays(relayIdx, 2))
                    edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                    obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                    obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                else
                    edgeIdx = findEdgeIdx(obj,fliplr(relays(relayIdx, 1:2)));
                    obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                    obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                end
                specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},'Color',"--mw-graphics-colorOrder-10-primary");
            % Highlight Friendship transmissions
            elseif ~isempty(obj.FriendPairs) && any(ismember(obj.FriendPairs, [relays(relayIdx, 1), ...
                    relays(relayIdx, 2)], 'rows')) && ...
                    ~any(ismember(obj.pTransmissionIDs, relays(relayIdx, 3)))
                edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                obj.pEdgeLines{edgeIdx}.LineWidth = 5;
            elseif ~isempty(obj.FriendPairs) && any(ismember(obj.FriendPairs, [relays(relayIdx, 2), ...
                    relays(relayIdx, 1)], 'rows')) && ...
                    ~any(ismember(obj.pTransmissionIDs, relays(relayIdx, 3)))
                edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                obj.pEdgeLines{edgeIdx}.LineWidth = 5;
            % Highlight normal transmissions
            elseif relays(relayIdx, 3)
                if ~isempty(obj.pSrcDstPairs)
                    % New transmission ID
                    if ~ismember(relays(relayIdx, 3), obj.pTransmissionIDs)
                        pairIdx = find(ismember(obj.pSrcDstPairs(:, 1), relays(relayIdx, 1)));
                        if ~isempty(pairIdx)
                            for pairIndex = 1 : length(pairIdx)
                                if obj.pTransmissionIDs(pairIdx(pairIndex)) == -1
                                    obj.pTransmissionIDs(pairIdx(pairIndex)) = relays(relayIdx, 3);
                                    % Highlight new transmission ID
                                    color = obj.Colors(pairIdx(pairIndex), :);
                                    if obj.NodeType(relays(relayIdx, 2)) % Node off check
                                        obj.pHighlightNodes{relays(relayIdx,2)}.SizeData = 100;
                                        if edgecount(obj.pGraph, relays(relayIdx, 1), relays(relayIdx, 2))
                                            edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                                            obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                                            obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                                        else
                                            edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                                            obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                                            obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                                        end
                                        specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},'Color',color);
                                    end
                                    break;
                                end
                            end
                        else
                            continue;
                        end
                    % Highlight for an existing transmission ID
                    else
                        colorIdx = ismember(obj.pTransmissionIDs, relays(relayIdx, 3));
                        color = obj.Colors(colorIdx, :);
                        if obj.NodeType(relays(relayIdx, 2)) % Node off check
                            obj.pHighlightNodes{relays(relayIdx, 1)}.SizeData = 100;
                            obj.pHighlightNodes{relays(relayIdx, 2)}.SizeData = 100;
                            if edgecount(obj.pGraph, relays(relayIdx, 1), relays(relayIdx, 2))
                                edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                                obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                                obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                            else
                                edgeIdx = findEdgeIdx(obj,fliplr(relays(relayIdx, 1:2)));
                                obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                                obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                            end
                            specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},'Color',color);
                        end
                    end
                end
            end
        end
                
        % Normalize the current transmission
        pause(0.3);
        
        % Check for empty figure handle
        if (~isvalid(obj.pFigureObj))
            return;
        end
        
        for relayIdx = 1 : relayCount
            % Normalize the source node
            if ~ismember(relays(relayIdx, 1), obj.pSrcDstPairs) && ...
                    ~ismember(relays(relayIdx, 1), obj.FriendPairs)
                obj.pHighlightNodes{relays(relayIdx, 1)}.SizeData = 50;
            end
            
            % Normalize the destination node
            if (~ismember(relays(relayIdx, 2), obj.pSrcDstPairs)) && ...
                    (~ismember(relays(relayIdx, 2), obj.FriendPairs))
                obj.pHighlightNodes{relays(relayIdx, 1)}.SizeData = 50;
            end
                
            % Normalize friend transmissions
            if ~isempty(obj.FriendPairs) && ...
                    (any(ismember(obj.FriendPairs, [relays(relayIdx, 1), relays(relayIdx, 2)], 'rows')) || ...
                    any(ismember(fliplr(obj.FriendPairs), [relays(relayIdx, 1), relays(relayIdx, 2)], 'rows')))
                edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                obj.pEdgeLines{edgeIdx}.LineStyle = '-.';
                obj.pEdgeLines{edgeIdx}.LineWidth = 0.5;
                specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},"Color","--mw-graphics-colorNeutral-line-primary");
            else               
                % Normalize the transmission based on the path already
                % shown
                pathFlag = 0;
                if ~isempty(obj.pPaths)
                    for pathIdx = 1:size(obj.pPaths, 1)
                        % Check if edge is member of path
                        if diff(find(ismember(obj.pPaths(pathIdx, :), relays(relayIdx, 1:2)))) == 1
                            path = nonzeros(obj.pPaths(pathIdx, :));
                            
                            % Get index based on source-destination pair
                            pairIndx = 0;
                            pairIdxs = find(ismember(obj.pSrcDstPairs, path(1))); % Compare with source
                            for pairIndex = 1:length(pairIdxs)
                                % Compare with destination
                                if any(ismember(obj.pSrcDstPairs(pairIdxs(pairIndex), :), path(end)))
                                    pairIndx = pairIdxs(pairIndex);
                                    break;
                                end
                            end
                            % Get pair index if Friend node is the
                            % destination node
                            if ~isempty(obj.FriendPairs) && ~pairIndx
                                frndIdx = find(obj.FriendPairs(:, 1) == path(end), 1);
                                if ~isempty(frndIdx)
                                    if any(ismember(obj.pSrcDstPairs(pairIdxs, :), obj.FriendPairs(frndIdx, 2)))
                                        pairIndx = pairIdxs;
                                    end
                                end
                            end
                            % Highlight the given path
                            for elementIdx = 1:numel(path)-1
                                if edgecount(obj.pGraph, path(elementIdx), path(elementIdx+1))
                                    edgeIdx = findEdgeIdx(obj,[path(elementIdx),path(elementIdx+1)]);
                                    obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                                else
                                    edgeIdx = findEdgeIdx(obj,[path(elementIdx+1), path(elementIdx)]);
                                    obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                                end
                                specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},'Color',obj.Colors(pairIndx, :));
                            end
                            pathFlag = 1;
                        end
                    end
                end
                % Edge is not member of any shown path
                if ~pathFlag && obj.NodeType(relays(relayIdx, 2))
                    if edgecount(obj.pGraph, relays(relayIdx, 1), relays(relayIdx, 2))
                        edgeIdx = findEdgeIdx(obj,relays(relayIdx, 1:2));
                        obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                        obj.pEdgeLines{edgeIdx}.LineWidth = 1;
                    else
                        edgeIdx = findEdgeIdx(obj,fliplr(relays(relayIdx, 1:2)));
                        obj.pEdgeLines{edgeIdx}.LineStyle = '-';
                        obj.pEdgeLines{edgeIdx}.LineWidth = 1;
                    end
                    specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},'Color',"--mw-graphics-colorNeutral-region-secondary");
                end
            end
        end
    end
    
    % Show path from source to destination
    function showPath(obj, path)

        import matlab.graphics.internal.themes.specifyThemePropertyMappings
        % Check for network creation
        if isempty(obj.pFigureObj)
            fprintf('createNetwork() must be called first.\n');
            return;
        elseif (~isvalid(obj.pFigureObj))
            return;
        elseif (obj.pPathCount >= 21)
            return;
        end
        
        % Validate path
        validateattributes(path, {'numeric'}, {'vector', '>=', 1, ...
            '<=', obj.NumberOfNodes}, 'showPath');
        
        % Node off check, to identify off nodes in the path
        if (sum(~obj.NodeType(path)))
            fprintf('All nodes in the path must be on\n');
            return;
        end
        
        % Get index based on source-destination pair
        pairIndx = 0;
        pathStr = blanks(0);
        pairIdxs = find(ismember(obj.pSrcDstPairs, path(1))); % Compare with source
        for idx = 1:length(pairIdxs)
            % Compare with destination
            if any(ismember(obj.pSrcDstPairs(pairIdxs(idx), :), path(end)))
                pairIndx = pairIdxs(idx);
                pathStr = 'Path from Source to Destination (';
                break;
            end
        end
        % Get pair index when path having Friend node as the destination
        if ~isempty(obj.FriendPairs) && ~pairIndx
            frndIdx = find(obj.FriendPairs(:, 1) == path(end), 1);
            if ~isempty(frndIdx)
                if any(ismember(obj.pSrcDstPairs(pairIdxs, :), obj.FriendPairs(frndIdx, 2)))
                    pairIndx = pairIdxs;
                    pathStr = 'Path from Source to Friend (';
                else
                    return;
                end
            else
                return;
            end
        end
        
        % Highlight the given path
        if pairIndx
            for idx = 1:numel(path)-1
                if edgecount(obj.pGraph, path(idx), path(idx+1))
                    edgeIdx = findEdgeIdx(obj,[path(idx), path(idx+1)]);
                    obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                else
                    edgeIdx = findEdgeIdx(obj,[path(idx+1), path(idx)]);
                    obj.pEdgeLines{edgeIdx}.LineWidth = 5;
                end
                specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},'Color',obj.Colors(pairIndx, :));
            end
        else
            return;
        end
        
        % Store paths
        for i = 1 : length(path)
            obj.pPaths(obj.pPathCount+1, i) = path(i);
        end
        
        % Display path when destination reached
        switch obj.pPathCount + 1
            case 1
                pathDim = [0.67 0.55 0.2 0.1];
                tag = 'Path1';
            case 2
                pathDim = [0.67 0.45 0.2 0.1];
                tag = 'Path2';
            case 3
                pathDim = [0.67 0.35 0.2 0.1];
                tag = 'Path3';
            case 4
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path4';
            case 5
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path5';
            case 6
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path6';
            case 7
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path7';
            case 8
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path8';
            case 9
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path9';
            case 10
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path10';
            case 11
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path11';
            case 12
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path12';
            case 13
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path13';
            case 14
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path14';
            case 15
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path15';
            case 16
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path16';
            case 17
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path17';
            case 18
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path18';
            case 19
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path19';
            case 20
                pathDim = [0.67 0.25 0.2 0.1];
                tag = 'Path20';
            otherwise
                fprintf('Maximum of 4 paths can be displayed in the plot.\n');
                return;
        end
        dim = pathDim;
        str = [pathStr num2str(path(1)) ', ' num2str(path(end)) '): ' replace(num2str(path), '  ', ', ')];
        annHandle = annotation(obj.pFigureObj, 'textbox', dim, 'String', str, 'FitBoxToText', 'on', ...
            'Tag', tag, 'HorizontalAlignment','left', 'VerticalAlignment', 'middle', 'FontUnits','normalized', 'LineStyle', 'none');
        specifyThemePropertyMappings(annHandle,'color',obj.Colors(pairIndx, :));

        % Increment path count
        obj.pPathCount = obj.pPathCount + 1;
    end
    
    % Highlight destination node when reached
    function highlightDstNode(obj, nodeID)
        % Check for network creation
        if isempty(obj.pFigureObj)
            fprintf('createNetwork() must be called first.\n');
            return;
        elseif (~isvalid(obj.pFigureObj))
            return;
        end
        
        % Validate node ID
        validateattributes(nodeID, {'numeric'}, {'scalar', 'integer', ...
            '>=', 1, '<=', obj.NumberOfNodes}, 'highlightDstNode');
        
        % Node off check
        if ~obj.NodeType(nodeID)
            fprintf('To highlight transmissions, node must be in ''On'' state.\n');
            return;
        end

        obj.pHighlightNodes{nodeID}.SizeData = 140;
        pause(0.15);
        % Check for empty figure handle
        if (~isvalid(obj.pFigureObj))
            return;
        end

        obj.pHighlightNodes{nodeID}.SizeData = 100;
        pause(0.15);
        % Check for empty figure handle
        if (~isvalid(obj.pFigureObj))
            return;
        end
    end
    
    % Change state of the node to on or off
    function updateNodeState(obj, nodeID, nodeState)
        % Check for network creation
        if isempty(obj.pFigureObj)
            fprintf('createNetwork() must be called first.\n');
            return;
        elseif (~isvalid(obj.pFigureObj))
            return;
        end
        
        % Validate node ID
        validateattributes(nodeID, {'numeric'}, {'scalar', 'integer', ...
            '>=', 1, '<=', obj.NumberOfNodes}, 'updateNodeState');
        
        % Validate node state
        validateattributes(nodeState, {'numeric'}, {'scalar', 'integer', ...
            '>=', 0, '<=', 2}, 'updateNodeState');
        
        % Update node state
        obj.NodeType(nodeID) = nodeState;
        
        % The network is recreated to change the node state
        obj.plotNetwork();
    end
    
    % Update node statistics
    function updateNodeStatistics(obj, statistics)

        import matlab.graphics.internal.themes.specifyThemePropertyMappings
        % Check for network creation
        if isempty(obj.pFigureObj)
            fprintf('createNetwork() must be called first.\n');
            return;
        elseif (~isvalid(obj.pFigureObj))
            return;
        end
        
        % Validate statistics
        statsCount = numel(statistics);
        if (~iscell(statistics) || (statsCount ~= obj.NumberOfNodes))
            fprintf('Statistics value must be a cell array of size %d.\n', obj.NumberOfNodes);
            return;
        end
        
        % Display node information on hover
        dcm = datacursormode;
        datacursormode off;
        
        % Connect helperBLEMeshGraphCursorCallback function to the data cursor
        set(dcm, 'update', {@helperBLEMeshGraphCursorCallback, statistics});
    end
    
    % Update Low Power node state
    function updateLowPowerNodeState(obj, nodeID, state)

        import matlab.graphics.internal.themes.specifyThemePropertyMappings
        % Check for network creation
        if isempty(obj.pFigureObj)
            fprintf('createNetwork() must be called first.\n');
            return;
        elseif (~isvalid(obj.pFigureObj))
            return;
        end
        
        % Change node color based on Low Power node state
        switch state
            case 0 % Sleep
                specifyThemePropertyMappings(obj.pHighlightNodes{nodeID},"NodeColor","--mw-graphics-colorOrder-8-primary")
            otherwise % Active
                idx = 0;
                for i = 1:size(obj.pSrcDstPairs, 1)
                    res = find(ismember(obj.pSrcDstPairs(i, :), nodeID), 1);
                    if ~isempty(res)
                        idx = i;
                        break;
                    end
                end
                if idx
                    specifyThemePropertyMappings(obj.pHighlightNodes{nodeID},"NodeColor",obj.Colors(idx(1), :));
                end
        end
    end
    
    function updateProgressBar(obj, currentTime)
        % Check for network creation
        if isempty(obj.pFigureObj)
            fprintf('createNetwork() must be called first.\n');
            return;
        elseif (~isvalid(obj.pFigureObj))
            return;
        end
        
        %updateProgressBar Update the progress bar status
        if (obj.SimulationTime)
            % Update simulation progress
            percentage = (currentTime/obj.SimulationTime)*100;
            obj.pProgressInfo.Position(3) = obj.ProgressW*(percentage/100);
            obj.pPercentageInfo.String = [ num2str(round(percentage)) '%'];
            pause(0.01);
        end
    end
end

methods (Access = private)
    function plotNetwork(obj)

        import matlab.graphics.internal.themes.specifyThemePropertyMappings
        % Create graph
        nw = digraph;
        axes(obj.pFigureObj, 'Position', [0.08, 0.1, 0.75, 0.8]);
        
        % Add nodes to the graph
        nw = addnode(nw, obj.NumberOfNodes);

        % Get vicinity nodes and create edges
        for i = 1:obj.NumberOfNodes
            % Get nodes in the vicinity to draw edges
            nodes = obj.vicinityNodes(i, obj.Positions, obj.ReceiverRange);
            for j = 1 : length(nodes)
                % Add bi-directional edges for friend pairs
                if ~isempty(obj.FriendPairs)
                    if ((obj.NodeType(i) == 3 && obj.NodeType(nodes(j)) == 4) || ...
                            (obj.NodeType(i) == 4 && obj.NodeType(nodes(j)) == 3)) && ...
                            (any(ismember(obj.FriendPairs, [i, nodes(j)], 'rows')) || ...
                            any(ismember(obj.FriendPairs, [nodes(j), i], 'rows')))
                        if ~sum(findedge(nw, nodes(j), i)) && ~sum(findedge(nw, i, nodes(j)))
                            nw = addedge(nw, i, nodes(j));
                        end
                    end
                end
                idx = findedge(nw, nodes(j), i);
                if ~idx
                    nw = addedge(nw, i, nodes(j));
                end
            end
        end

        % Store graph object
        obj.pGraph = nw;
        
        % Plot graph
        title(obj.Title);
        
        % Label axes
        xlabel(obj.pFigureObj.CurrentAxes, 'X-position (meters)', 'Tag', 'XLabel');
        ylabel(obj.pFigureObj.CurrentAxes, 'Y-position (meters)', 'Tag', 'YLabel');
        obj.pFigureObj.CurrentAxes.XTickMode = 'auto';
        obj.pFigureObj.CurrentAxes.YTickMode = 'auto';
        obj.pFigureObj.CurrentAxes.Box = 'off';
        obj.pFigureObj.CurrentAxes.TickDir = 'out';
        obj.pFigureObj.CurrentAxes.Tag = 'PlotAxes';
        obj.pFigureObj.CurrentAxes.ClippingStyle = 'rectangle';
        
        % Assign positions to graph nodes
        plotObjXData = obj.Positions(:, 1);
        plotObjYData = obj.Positions(:, 2);

        hold on

        obj.pHighlightNodes = cell(0,obj.NumberOfNodes);
        numEdges = size(nw.Edges,1);
        edgeNum = nw.Edges.EndNodes;
        for idx = 1:numEdges
            obj.pEdgeLines{idx} = plot([obj.Positions(edgeNum(idx,1),1) obj.Positions(edgeNum(idx,2),1)],[obj.Positions(edgeNum(idx,1),2) obj.Positions(edgeNum(idx,2),2)],'LineStyle','--');
            specifyThemePropertyMappings(obj.pEdgeLines{idx},"Color","--mw-graphics-colorNeutral-region-secondary");
        end
        
        obj.pEdges = edgeNum;
        
        % Mark relay node color as red
        for i = 1: obj.NumberOfNodes
            switch obj.NodeType(i)
                case 0 % Node off
                    % Get vicinity nodes of the current node
                    vicNodes = obj.vicinityNodes(i, obj.Positions, obj.ReceiverRange);
                    obj.pHighlightNodes{i} = scatter(plotObjXData(i),plotObjYData(i),"filled",'MarkerFaceColor',[0.8 0.8 0.8],'SizeData',50);
                    specifyThemePropertyMappings(obj.pHighlightNodes{i},"MarkerFaceColor",obj.NodeColors(5))
                    for j = 1:length(vicNodes)
                        if edgecount(nw, i, vicNodes(j))
                            edgeIdx = findEdgeIdx(obj,[i, vicNodes(j)]);
                            obj.pEdgeLines{edgeIdx}.LineWidth = 1.5;
                            specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},"Color",obj.NodeColors(5))
                        else
                            edgeIdx = findEdgeIdx(obj,[vicNodes(j) i]);
                            obj.pEdgeLines{edgeIdx}.LineWidth = 1.5;
                            specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},"Color",obj.NodeColors(5))
                        end                        
                    end
                    text(plotObjXData(i)+1,plotObjYData(i),string(i))
                case 1 % Nodes
                    obj.pHighlightNodes{i} = scatter(plotObjXData(i),plotObjYData(i),"filled",'SizeData',50);
                    text(plotObjXData(i)+1,plotObjYData(i),string(i))
                    specifyThemePropertyMappings(obj.pHighlightNodes{i},'MarkerFaceColor',obj.NodeColors(1));
                case 2 % Relay nodes
                    obj.pHighlightNodes{i} = scatter(plotObjXData(i),plotObjYData(i),"filled",'SizeData',50);
                    text(plotObjXData(i)+1,plotObjYData(i),string(i))
                    specifyThemePropertyMappings(obj.pHighlightNodes{i},'MarkerFaceColor',obj.NodeColors(2));
                case 3 % Friend node
                    obj.pHighlightNodes{i} = scatter(plotObjXData(i),plotObjYData(i),"filled",'SizeData',70);
                    text(plotObjXData(i)+1,plotObjYData(i),string(i))
                    specifyThemePropertyMappings(obj.pHighlightNodes{i},'MarkerFaceColor',obj.NodeColors(3));
                case 4 % Low Power node
                    obj.pHighlightNodes{i} = scatter(plotObjXData(i),plotObjYData(i),"filled",'SizeData',70);
                    text(plotObjXData(i)+1,plotObjYData(i),string(i))
                    specifyThemePropertyMappings(obj.pHighlightNodes{i},'MarkerFaceColor',obj.NodeColors(4));
            end
        end
        
        % Highlight friend connection with dashed lines
        for i = 1 : size(obj.FriendPairs, 1)
            edgeIdx = findEdgeIdx(obj,obj.FriendPairs(i, :));
            obj.pEdgeLines{edgeIdx}.LineStyle = '-.';
            specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},"Color",obj.NodeColors(5))
            edgeIdx = findEdgeIdx(obj,fliplr(obj.FriendPairs(i, :)));
            obj.pEdgeLines{edgeIdx}.LineStyle = '-.';
            specifyThemePropertyMappings(obj.pEdgeLines{edgeIdx},"Color",obj.NodeColors(5))
        end
		
		% Create empty plots for legend
        legendStr = {'Node', 'Relay node'};
        hold on;
        p(1) = plot(NaN, '.', 'MarkerSize', 30);
        specifyThemePropertyMappings(p(1),"Color",obj.NodeColors(1));
        p(2) = plot(NaN, '.', 'MarkerSize', 30);
        specifyThemePropertyMappings(p(2),"Color",obj.NodeColors(2));
        plotCount = 2;
        
        % Failed node legend
        if any(~obj.NodeType)
            p(plotCount+1) = plot(NaN, '.', 'MarkerSize', 30);
            specifyThemePropertyMappings(p(plotCount+1),"Color",obj.NodeColors(5))
            legendStr{plotCount+1} = 'Failed node';
            plotCount = plotCount + 1;
        end
         
        % Create legend for Friend node and Low Power node
        if size(obj.FriendPairs, 1) >= 1
            % Friend node legend
            p(plotCount+1) = plot(NaN, '.', 'MarkerSize', 30);
            specifyThemePropertyMappings(p(plotCount+1),"Color",obj.NodeColors(3));
            legendStr{plotCount+1} = 'Friend node';
            % Low Power node legend
            p(plotCount+2) = plot(NaN, '.', 'MarkerSize', 30);
            specifyThemePropertyMappings(p(plotCount+2),"Color",obj.NodeColors(4));
            legendStr{plotCount+2} = 'Low Power node';
            plotCount = plotCount + 2;
        end
        
        % More than 20 source-destination pairs
        if size(obj.SourceDestinationPairs, 1) > 20
            obj.SourceDestinationPairs = obj.SourceDestinationPairs(1:20, :);
            fprintf('Maximum of 20 source-destination pairs supported.\n');
        end
        
        validPairCount = 1;
        for k = 1:size(obj.SourceDestinationPairs, 1)
            % Get non-zero elements from pair
            srcDstPair = obj.SourceDestinationPairs(k, :);
            validSrcDstPair = srcDstPair(srcDstPair ~= 0);
            
            % Highlight source node
            if (obj.NodeType(srcDstPair(1)) == 4)
                fprintf('Low Power node is not supported as a source node.\n');
                continue;
            elseif ~obj.NodeType(srcDstPair(1))
                fprintf('Source node must not be a failed node.\n');
                continue;
            elseif (obj.NodeType(srcDstPair(1)) ~= 3)
                nodeIdx = obj.SourceDestinationPairs(k, 1);
                obj.pHighlightNodes{nodeIdx} = scatter(plotObjXData(nodeIdx),plotObjYData(nodeIdx),"filled",'SizeData',80);
                specifyThemePropertyMappings(obj.pHighlightNodes{nodeIdx},'MarkerFaceColor',obj.Colors(validPairCount, :));
            end
            obj.pSrcDstPairs(validPairCount, :) = srcDstPair;
            validPairCount = validPairCount + 1;
            % Highlight destination node
            for i = 1:numel(validSrcDstPair(2:end))
                if (obj.NodeType(validSrcDstPair(i+1))) && ...
                        (obj.NodeType(validSrcDstPair(i+1)) ~= 3) && ...
                        (obj.NodeType(validSrcDstPair(i+1)) ~= 4)
                    nodeIdx = validSrcDstPair(i+1);
                    obj.pHighlightNodes{nodeIdx} = scatter(plotObjXData(nodeIdx),plotObjYData(nodeIdx),"filled",'SizeData',80);
                    specifyThemePropertyMappings(obj.pHighlightNodes{nodeIdx},'MarkerFaceColor',obj.Colors(validPairCount-1, :))
                end
            end
            
            % Add legend for source-destination pairs
            p(plotCount+1) = plot(NaN, '.', 'MarkerSize', 30);
            specifyThemePropertyMappings(p(plotCount+1),'color',obj.Colors(validPairCount-1, :));
            if numel(validSrcDstPair(2:end)) > 1
                legendStr{plotCount+1} = ['Source-Destinations group (' ...
                    num2str(validSrcDstPair(1)) ' - ' replace(num2str(validSrcDstPair(2:end)), '  ', ', ') ')'];
            else
                legendStr{plotCount+1} = ['Source-Destination pair (' ...
                    num2str(validSrcDstPair(1)) ', ' num2str(validSrcDstPair(2)) ')'];
            end
            plotCount = plotCount+1;
        end
                
        hold off;
        legend(p, legendStr, 'Location', 'northeastoutside', ...
            'Box', 'off');
        obj.pFigureObj.CurrentAxes.XLim = [obj.pFigureObj.CurrentAxes.XLim(1)-10 obj.pFigureObj.CurrentAxes.XLim(2)+10];
        obj.pFigureObj.CurrentAxes.YLim = [obj.pFigureObj.CurrentAxes.YLim(1)-10 obj.pFigureObj.CurrentAxes.YLim(2)+10];
        
        % Call node statics to remove default values
        obj.updateNodeStatistics(cell(1, obj.NumberOfNodes));
        
        % For static visualization
        if obj.DisplayProgressBar
            % Progress bar dimensions
            progressDimension = [obj.ProgressX, obj.ProgressY, obj.ProgressW, obj.ProgressH];
            
            % Add progress bar
            anntn = annotation(obj.pFigureObj, 'rectangle', progressDimension, ...
                'Tag', 'MeshVisualizationProgressBar');
            specifyThemePropertyMappings(anntn,"FaceColor",obj.ProgressBarBackgroundColor)
            obj.pProgressInfo = annotation(obj.pFigureObj, 'rectangle', ...
                progressDimension, 'Tag', 'MeshVisualizationProgressBar');
            specifyThemePropertyMappings(obj.pProgressInfo,"FaceColor",obj.ProgressBarColor)
            obj.pProgressInfo.Position(3) = 0;
            % Progress percentage display text
            obj.pPercentageInfo = annotation(obj.pFigureObj, 'textbox', ...
                progressDimension, 'String', '0%', ...
                'FitBoxToText', 'on', 'FontUnits', 'normalized', ...
                'LineStyle', 'none', 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Tag', ...
                'MeshVisualizationProgressBarPercentage');
        end
    end
    
    % Allocate the grid positions
    function positions = gridPositionAllocator(obj)
        x = zeros(1, obj.NumberOfNodes);
        y = zeros(1, obj.NumberOfNodes);
        for i = 1:(obj.NumberOfNodes)
            switch(obj.GridLayout)
                case 'Row' % Arrange nodes row by row
                    x(i) = obj.GridInitX + obj.GridDeltaX*(mod(i-1, obj.GridWidth));
                    y(i) = obj.GridInitY + obj.GridDeltaY*(floor((i-1)/obj.GridWidth));
                    
                case 'Column' % Arrange nodes column by column
                    x(i) = obj.GridInitX + obj.GridDeltaX*(floor(i-1/obj.GridWidth));
                    y(i) = obj.GridInitY + obj.GridDeltaY*(mod(i-1, obj.GridWidth));
                    
                otherwise
                    fprintf('Invalid layout type. Valid options are ''Row'' and ''Column''.\n');
            end
        end
        positions = [x', y'];
    end
    
    % Validate positions
    function validatePositions(obj, value)
        validateattributes(value, {'numeric'}, {'2d', 'ncols', 2, ...
            'nrows', obj.NumberOfNodes}, mfilename, 'Positions');
    end
    
    % Validate node state
    function validateNodeType(obj, value)
        validateattributes(value, {'numeric'}, {'row', 'numel', ...
            obj.NumberOfNodes, '>=', 0, '<=', 4}, mfilename, 'NodeType');
    end
	
	% Validate source-destination pairs
    function validateSrcDstPairs(obj, value)
        validateattributes(value, {'numeric'}, ...
        {'nonnegative', '<=', obj.NumberOfNodes, '>=', 0}, mfilename, 'SourceDestinationPairs');
    end
    
    % Validate friend pairs
    function validateFriendPairs(obj, value)
        validateattributes(value, {'numeric'}, ...
        {'nonnegative', '<=', obj.NumberOfNodes, '>=', 1, 'ncols', 2}, mfilename, 'SourceDestinationPairs');
    end

    function edgeIdx = findEdgeIdx(obj,nodeIDs)
        %findEdgeIdx Returns the index of the edge from the edge list based on the
        %node IDs
        
        edgeIdx = 0;
        for idx = 1:size(obj.pEdges,1)
            % Check the presence of nodeIDs in the edge list
            if isequal(obj.pEdges(idx,:),nodeIDs)
                edgeIdx= idx;
                break;
            end
        end

        % Check if the node IDs are present in flipped way in the edge list
        if edgeIdx==0
            for idx = 1:size(obj.pEdges,1)
                if isequal(obj.pEdges(idx,:),fliplr(nodeIDs))
                    edgeIdx= idx;
                    break;
                end
            end
        end
    end
end

methods (Static)
    function vicinityNodeIDs = vicinityNodes(nodeID, positions, receiverRange)
        %vicinityNodes Get vicinity nodes (nodes in the receiver range) of
        %the given node.
        %   VICINITYNODEIDS = vicinityNodes(NODEID, POSITIONS,
        %   RECEIVERRANGE) returns vicinity node IDs of a given node.
        %
        %   VICINITYNODEIDS is a vector of node IDs which are in the
        %   receiver range of given node.
        %
        %   NODEID is an integer.
        %
        %   POSITIONS is an array of all node positions in the network.
        %
        %   RECEIVERRANGE is an integer which indicates the transmission
        %   and reception range of the node.

        % Source node position
        sourceNodePos = [positions(nodeID, 1), positions(nodeID, 2)];

        % Distance between source node and remaining nodes in the network
        distance = sqrt(((positions(:, 1)-sourceNodePos(1)).^2) + (positions(:, 2)-sourceNodePos(2)).^2);

        % Get vicinity nodes based on vicinity range
        vicinityNodeIDs = find(distance <= receiverRange);
        vicinityNodeIDs(vicinityNodeIDs == nodeID) = [];
    end
end
end
