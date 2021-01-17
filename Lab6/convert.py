with open("memory.hex","r") as f:
    s=f.read()
print(len(s))
with open("Memory_Read.txt","w") as f:
    for i in range(len(s)//4):
        f.write(s[4*i+2:4*(i+1)]+s[4*i:4*i+2])
        f.write("\n")
