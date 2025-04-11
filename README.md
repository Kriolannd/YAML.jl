# YAML.jl
Julia wrapper package for parsing `yaml` files 

USAGE
---
```
using YAML

yaml_str = """
retCode: 0
retMsg: "OK"
result:
  ap: 0.6636
  bp: 0.6634
  h: 0.6687
  l: 0.6315
  lp: 0.6633
  o: 0.6337
  qv: 1.1594252877069e7
  s: "ADAUSDT"
  t: "2024-03-25T19:05:35.491000064"
  v: 1.780835204e7
retExtInfo: {}
time: "2024-03-25T19:05:38.912999936"
"""

julia> parse_yaml_str(yaml_str)
1-element Vector{Dict{Any, Any}}:
 Dict(
  "retExtInfo" => Dict{Any, Any}(),
  "time" => "2024-03-25T19:05:38.912999936",
  "retCode" => "0",
  "retMsg" => "OK",
  "result" => Dict{Any, Any}("v" => "1.780835204e7", "ap" => "0.6636", "o" => "0.6337", "t" => "2024-03-25T19:05:35.491000064", "qv" => "1.1594252877069e7", "bp" => "0.6634", "l" => "0.6315", "lp" => "0.6633", "h" => "0.6687", "s" => "ADAUSDT"…))
```
