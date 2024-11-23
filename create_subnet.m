function [subnet, inital_provisioner_node, provisoionee_indexes, outer_shell] = create_subnet(generation_list, current_generation, node_list)
    % Move the starting node to the id = 1 position
    starting_node_id = generation_list{1};
    starting_node_position = node_list(starting_node_id, :);
    subnet = [starting_node_position];
    % For each of the generations up till the currently selected one
    % add the nodes corresponding to that generation to the subnet
    neighbor_positions = [];
    for i = 2:current_generation
        nodes = generation_list{i};
        neighbor_positions = node_list(nodes, :);
        subnet = [subnet; neighbor_positions];
    end
    % Since we reorder the nodes, this will always be one
    inital_provisioner_node = 1;
    last_gen_length = length(generation_list{current_generation});
    subnet_length = size(subnet, 1);
    % The provisionees are the last nodes added to the subnet
    provisoionee_indexes = (subnet_length-last_gen_length+1:subnet_length)';
    outer_shell = neighbor_positions;
end