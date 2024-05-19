import pandas as pd
import matplotlib.pyplot as plt

#reads the results file and performs simple statistical calculations
data_file= input("Enter the data file: ")
data = pd.read_csv(data_file)

print(data.columns)

#creates a table of the original measurements as an image
fig1, ax1 = plt.subplots(figsize=(8, 3))
ax1.axis('off')
ax1.axis('tight')
ax1.table(cellText=data.values, colLabels=data.columns, rowLabels=data.index, cellLoc = 'center', loc='center')
plt.savefig('delay_measurements_table.png')
plt.show()

#creates a graph of bandwidth against delay
plt.figure(figsize=(12, 8))
plt.plot(data['Delay (ms)'], data['Bandwidth (Mbits/sec)'])
plt.xlabel('Delay (ms)')
plt.ylabel('Bandwidth (Mbits/sec)')
plt.title(f'Graph of Bandwidth (Mbits/sec) against increaseing delay (ms)')
plt.tight_layout()
plt.savefig('delay_against_bandwidth.png')
plt.show()

plt.close()