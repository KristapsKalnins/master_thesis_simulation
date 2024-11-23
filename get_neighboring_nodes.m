function list = get_neighboring_nodes(cartesian_pos, neighbor_distance)
    % For each point in the matrix
    list = {[]};
    for i = 1:size(cartesian_pos, 1)
        % Calculate the distance from that all point to that point i
        neighbors = [];
        for j = 1:size(cartesian_pos, 1)
            % Exclude calculating distnace to oneself
            if(i ~= j)
                distance = pdist2(cartesian_pos(i,:),cartesian_pos(j,:),'euclidean');
                if(distance <= neighbor_distance)
                    neighbors = [neighbors; [j distance]];
                end
            end
        end
        list{i} = neighbors;
    end
end