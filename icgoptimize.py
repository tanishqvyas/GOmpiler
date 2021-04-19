f = open("quad.txt","r")
taclines = f.readlines()
taclength=len(taclines)
taclines =[i.strip().split(" ") for i in taclines]
labels = {taclines[i][-1]:i for i in range(taclength) if taclines[i][0]=="label"}
labels.update({taclines[i][1]:i for i in range(taclength) if taclines[i][1]=="begin"})
leaderlines=[0]
basicblocks=[]
ops=['+','-','*','/','<','>','<=','>=','==','!=']

def constant_propagation(block,comp=[]):

    vars = dict() 
    for b in block:
        line=b
        if (line[0]=='=' and line[1].isnumeric()):
            if line[3] not in vars:
                vars[line[3]] = line[1]
    final_list = []
    for b in block:
        line = b
        if(line[0] in ops):
            if line[1] in vars:
                line[1] = vars[line[1]]
            if line[2] in vars:
                line[2] = vars[line[2]]
        if(line[0] == '=' and line[1] in vars):
            line[1] = vars[line[1]]
        final_list.append(line)

    if(final_list == comp):
        return final_list,0
    else:
        return final_list,1

def constant_folding(block,comp=[]):
    final_list=[]
    for b in block:
        line=b
        if (line[0] in ops and line[1].isnumeric() and line[2].isnumeric()):
            line=['=',str(eval(line[1]+line[0]+line[2])),"",line[3]]
        final_list.append(line)
    if(final_list == comp):
        return final_list,0
    else:
        return final_list,1


for i in range(1,taclength):
    if(taclines[i][1]=="begin"):
        leaderlines.append(labels[taclines[i][1]])
    if(taclines[i][0]=="if" or taclines[i][0]=="GOTO"):
        lead=labels[taclines[i][3]]
        if(lead not in leaderlines):
            leaderlines.append(lead)
            if((i+1) not in leaderlines):
                leaderlines.append(i+1)

leaderlines.sort()
for i in range(len(leaderlines)-1):
    basicblocks.append(taclines[leaderlines[i]:leaderlines[i+1]])

print("NUMBER OF BASIC BLOCKS:",len(basicblocks))
for block in basicblocks:
    flag1 = 1
    flag2 = 1 
    n=1
    const_prop_list,flag1 = constant_propagation(block)
    const_fold_list,flag2 = constant_folding(const_prop_list)

    while int(flag1) or int(flag2):
        const_prop_list,flag1 = constant_propagation(const_fold_list,const_prop_list)
        const_fold_list,flag2 = constant_folding(const_prop_list,const_fold_list)
        n=n+1


    for i in const_fold_list:
        print(" ".join(i))
    