function value = hydraulicDiameter(a, b)
    %HYDRAULICDIAMETER Compute hydraulic diameter for a rectangular duct.

    alias = spf.load();
    value = calllib(alias, 'spf_hydraulic_diameter', double(a), double(b));
end
