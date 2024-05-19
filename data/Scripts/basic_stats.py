import pandas as pd
import matplotlib.pyplot as plt

#reads the results file and performs simple statistical calculations
data_file= input("Enter the data file: ")
data = pd.read_csv(data_file)
stats = data.drop(columns=['Delay (ms)']).describe()

print(data.columns)

#creates a table of the original measurements as an image
fig1, ax1 = plt.subplots(figsize=(8, 3))
ax1.axis('off')
ax1.axis('tight')
ax1.table(cellText=data.values, colLabels=data.columns, rowLabels=data.index, cellLoc = 'center', loc='center')
plt.savefig("10ms_delay_measurements_table.png")
plt.show()

#creates a table with processed results
fig2, ax2 = plt.subplots(figsize=(8, 3))
ax2.axis('off')
ax2.axis('tight')
ax2.table(cellText=stats.values, colLabels=stats.columns, rowLabels=stats.index, cellLoc = 'center', loc='center')
plt.savefig("10ms_delay_description_table.png")
plt.show()

tcp_flows = range(1, len(data) + 1)

#creates a graph for each of the columns in the results table
for col, file_name in [("Transfer (GBytes)", "10ms_delay_transfer_plot.png"), 
                          ("Bandwidth (Mbits/sec)", "no_delay_bandwidth_plot.png"), 
                          ("irtt (microseconds)", "10ms_delay_irtt_plot.png")]:
    plt.figure(figsize=(12, 8))
    plt.plot(tcp_flows, data[col])
    if col == 'Bandwidth (Mbits/sec)':
        plt.ylim(900, 950)
    plt.xlabel('Flow Number')
    plt.ylabel(col)
    plt.title(f'Graph of {col} against Flow Number')
    plt.tight_layout()
    plt.savefig(file_name)
    plt.show()

plt.close()