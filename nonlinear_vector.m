function vec = nonlinear_vector(number_of_values, a, lower, upper)
    n = number_of_values;
    %n = 20;
    %a = 100;
    %lower = 1;
    %upper = 1.05;
    temp = exp(linspace(log(lower)*a,log(upper)*a,n))
    % re-scale to be between 0 and 1
    temp_01 = temp/max(temp) - min(temp)/max(temp)
    % re-scale to be between your limits (i.e. 1 and 1.05)
    vec = temp_01*(upper-lower) + lower
end