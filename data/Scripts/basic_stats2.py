import pandas as pd
import matplotlib.pyplot as plt

#reads the results file
data_file= input("Enter the data file: ")
data = pd.read_csv(data_file)

#values for the x-axis representing the transfer number
tcp_flows = range(1, len(data) + 1)

#label for each line
delays = ['0ms', '10ms', '20ms', '30ms', '40ms', '50ms', '60ms']

#creates a graph for the combined results
plt.figure(figsize=(12, 8))
for delay in delays:
    plt.plot(tcp_flows, data[delay], label=delay)

plt.xlabel('Flow Number')
plt.ylabel('Bandwidth (Mbites/sec)')
plt.title(f'Graph comparing the bandwidth for differnet levels of delay')
plt.legend(title='Delay', loc="upper right")
plt.tight_layout()
plt.savefig('combined_graph.png')
plt.show()