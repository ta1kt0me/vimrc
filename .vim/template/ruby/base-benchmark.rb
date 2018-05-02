require "benchmark/ips"

Benchmark.ips do |x|
  x.config time: 5, warmup: 2

  x.report("Pattern A") do
    {{_cursor_}}
  end

  x.report("Pattern B") do

  end

  x.compare!
end
