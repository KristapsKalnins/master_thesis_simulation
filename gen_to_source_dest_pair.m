function pairs = gen_to_source_dest_pair(gen, initial_node)
    pairs = [];
    for i=1:size(gen,1)
        pairs = [pairs; gen(i) initial_node];
    end
end