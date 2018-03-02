## Ruby Plot Nmap Thread Scanner

> This project was an experiment in Ruby while I was trying to find out when my laptop
> works faster when creating multiple threads to portscan the network with nmap.

### Current status
* _StandBy_

#### Features

* Displays a gnuplot with multiple datasets from pools/passes.

#### Screenshot
=> __8 Passes, with a thread pool of 20 threads__  

I'd say that a value between 9-10 is the best choice. Creating more threads causes instability and even slower speeds.

![Screenshot Running Command](/plot/top_ports_10_passes_20.png?raw=true "Running command screenshot")

### Install & Configuration

1. `bundle install`
2. Be sure you have already installed gnuplot executables. It depends on the distro - I am using Arch and `sudo pacman -S gnuplot`
3. Execute `ruby run.rb` and drink your coffee.

### How to Use?

When it's finished, the plot will pop up when you can export it.

- How do I initialize Scanner?
`sc = Scanner.new(<network>, <passes>, <pool>)`
  - __network:__ The network you want to scan e.g._'192.168.1.0/24'_
  - __passes:__ How many times to repeat scanning e.g. _8_
  - __pool:__ Maximum amount of threads in the pool e.g. _20_
