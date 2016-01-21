@stat_range = { hp: { name: "HP",
                          min: 1,
                          max: 18, },
                    mp: { name: "MP",
                          min: 3,
                          max: 123 } }
              
@stat_range.each do |stat, details|
  puts stat
  puts stat.to_s
  puts details
  puts details[:name]
  puts details[:min]
end