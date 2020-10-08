# https://stackoverflow.com/questions/53315791/how-to-convert-a-json-response-into-yaml-in-bash
#
# ln -sf yamlify.jq .jq
# env HOME=. jq -r yamlify2 tmp/nfs-triple.json

def yamlify:
  (objects | to_entries[] | (.value | type) as $type |
    if $type == "array" then
      "\(.key):", (.value | yamlify)
    elif $type == "object" then
      "\(.key):", "    \(.value | yamlify)"
    else
      "\(.key):\t\(.value)"
      end
  )
    // (arrays | select(length > 0)[] | [yamlify] |
         "  - \(.[0])", "    \(.[1:][])"
       )
    // .
;

def yamlify2:
  (objects | to_entries | (map(.key | length) | max + 2) as $w |
    .[] | (.value | type) as $type |
    if $type == "array" then
      "\(.key):", (.value | yamlify2)
    elif $type == "object" then
      "\(.key):", "    \(.value | yamlify2)"
    else
      "\(.key):\(" " * (.key | $w - length))\(.value)"
      end
  )
    // (arrays | select(length > 0)[] | [yamlify2] |
         "  - \(.[0])", "    \(.[1:][])"
       )
    // .
;
