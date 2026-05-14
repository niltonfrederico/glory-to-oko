function __oko_system_format_csv --description 'Convert the merged system JSON to a flat CSV (key.path,value)'
    # Flatten via jq into [key, value] rows so miller emits a clean
    # two-column CSV regardless of nesting depth. Lists collapse to one
    # row per element with the index in the key path (foo.0, foo.1...).
    jq -r '
        [paths(scalars) as $p | { key: ($p | join(".")), value: (getpath($p) | tostring) }]
    ' | mlr --ijson --ocsv cat
end
