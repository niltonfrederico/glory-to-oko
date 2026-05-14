function __oko_system_format_yaml --description 'Convert the merged system JSON to YAML'
    yq -p json -o yaml
end
