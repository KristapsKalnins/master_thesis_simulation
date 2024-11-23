function gen = get_provisioner_generations(nodes_and_neighbors, initial_node)
    gen = [];
    provisioned_nodes = [];
    provisioned_nodes = [provisioned_nodes initial_node];
    current_gen = [];
    fprintf("Gen 1\n")
    fprintf("%d\n", initial_node)
    current_gen = [current_gen ; initial_node];
    gen{1} = current_gen;
    gen_counter = 2;
    while(size(current_gen ,1) > 0)
        new_generation = [];
        fprintf("Gen %d\n", gen_counter);
        for i = 1:size(current_gen, 1)
            node_id = current_gen(i);
            neighbors = nodes_and_neighbors{node_id};
            for j = 1:size(neighbors, 1)
                if(~ismember(neighbors(j,1), provisioned_nodes))
                    fprintf("%d\t", neighbors(j,1));
                    new_generation = [new_generation; neighbors(j,1)];
                    provisioned_nodes = [provisioned_nodes neighbors(j,1)];
                end
            end 
        end
        fprintf("\n");
        gen{gen_counter} = new_generation;
        gen_counter = gen_counter + 1;
        current_gen = new_generation;
    end
end


 %fprintf("Gen 2\n")
    %for i = 1:size(nodes_and_neighbors{initial_node}, 1)
    %    neighbor = nodes_and_neighbors{initial_node}(i, 1);
    %    fprintf("%d\t", neighbor);
    %    provisioned_nodes = [provisioned_nodes neighbor];
    %    current_gen = [current_gen; neighbor];
    %end
    %fprintf("\n");