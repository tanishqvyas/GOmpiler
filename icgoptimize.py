import re

isidentifier = lambda s : bool(re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", s))
# Operators List
ops=['+','-','*','/','<','>','<=','>=','==','!=']

# Take input from the quad.txt
f = open("quad.txt","r")
taclines = f.readlines()
taclength=len(taclines)

# Split each line on space to get something of the form ["reparam", "a"]
taclines =[i.strip().split(" ") for i in taclines]

# Collect all the labels generated and the line number they refer to 
labels = {taclines[i][-1]:i for i in range(taclength) if taclines[i][0]=="label"}

# Collect function beginnings and add it to labels
labels.update({taclines[i][2]:i for i in range(taclength) if taclines[i][1]=="begin"})

# Leader line numbers for basic blocks
leaderlines=[0]

# 
basicblocks=[]


'''
# List out the steps to be done for pre prep in sequential points

#  1. Identification of leaders
    # We can have begin func as a leader
    # We can have goto target as leader
    # We can have if jump target as leader
    So,

    1. We will be parsing the quad file yes or no to find the leader lines ? yes   
    2. Now
        - if a line contains begin its leader
        - if a line contains, if / goto, lookup for corresponding label from dict
        - okay line after if also a label (how r u identifying this) ?
        - this is for ?  and if its not already added to leader, only then add it

        - cool, so is leader also a dict ? if no then why not ? eh ? because ?

        okay so lets code what we wrote till now okay then we will move ahead

        bring here

'''

# Find leaders in blocks
for i in range(1,taclength):

    # Searching if its beginning/end of func
    if(taclines[i][1]=="begin"):
        # Accessing function declaration line number from labels and appending to leader lines
        leaderlines.append(labels[taclines[i][2]])

    # Checking if it is a conditional / non conditional jump statement
    if(taclines[i][0]=="if" or taclines[i][0]=="GOTO"):
        
        # Calculate leader line
        lead=labels[taclines[i][3]]

        # Check if the line has already been added to leaderlines
        if(lead not in leaderlines):
            leaderlines.append(lead)
            
            # Check if the line after the conditional/unconditional jump has already been added to leaderlines
            if((i+1) not in leaderlines):
                leaderlines.append(i+1)



#  2. Creation of basic blocks
leaderlines.sort()
print("Lines with leaders in them are:", leaderlines)
if(len(leaderlines)==1):
        basicblocks.append(taclines[leaderlines[0]:])
else:
    for i in range(len(leaderlines)):
        if i == len(leaderlines)-1:
            basicblocks.append(taclines[leaderlines[i]:])
        else:
            basicblocks.append(taclines[leaderlines[i]:leaderlines[i+1]])

print("NUMBER OF BASIC BLOCKS:",len(basicblocks))


def constant_propagation(block,previous_state=[]):
    temp_block=block
    # Stores all variables and temporaries
    vars = {}
    final_block=[]
    # check for assignment operation and obtain all the variables assigned
    for line in block:
        if (line[0]=='=' and line[1].isnumeric()):
            if line[3] not in vars:
                vars[line[3]] = line[1]

    # Now constant propogate all the variables
    for b in block:
        line=b.copy()
        # check for any propogatable variables and propogate the value
        if(line[0] in ops):
            if line[1] in vars:
                line[1] = vars[line[1]]
            if line[2] in vars:
                line[2] = vars[line[2]]
        
        # for cases like y = 5, x = y
        if(line[0] == '=' and line[1] in vars):
            line[1] = vars[line[1]]
        final_block.append(line)
    block=temp_block

    if(final_block == previous_state):
        return final_block,0
    else:
        return final_block,1



def constant_folding(block,previous_state=[]):
    temp_block=block
    final_block = []
    for b in block:
        line=b.copy()
        if (line[0] in ops and line[1].isnumeric() and line[2].isnumeric()):

            # line=['=',str(eval(line[1]+line[0]+line[2])),"",line[3]]
            line[1] = str(eval(line[1]+line[0]+line[2]))
            line[0] = "="
            line[2] = ""
        final_block.append(line)
    block=temp_block
    if(final_block == previous_state):
        return final_block,0
    else:
        return final_block,1

def copy_propagation(block):

    # Stores all variables and temporaries
    vars = {}
    final_block=[]
    # check for assignment operation and obtain all the variables assigned
    for b in block:
        line=b.copy()
        for i in range(1, len(line)-1):
            if line[i] in vars:
                line[i]=vars[line[i]]
        final_block.append(line)

        if (line[0]=='=' and isidentifier(line[1]) and isidentifier(line[3])):
                vars[line[3]] = line[1]

    return final_block



def dead_code_elimination(block):
    rhs_vars=set()
    all_vars=set()
    # collect all vars
    # collect rhs vars
    num_lines=len(block)
    for line in block:
        if line[0]=="=":
            if isidentifier(line[1]):
                all_vars.add(line[1])
                rhs_vars.add(line[1])
            all_vars.add(line[-1])
            if(line[-1] in rhs_vars):
                rhs_vars.discard(line[-1])
        if line[0] in ops:
            if isidentifier(line[1]):
                all_vars.add(line[1])
                rhs_vars.add(line[1])
            if isidentifier(line[2]):
                all_vars.add(line[2])
                rhs_vars.add(line[2])
            all_vars.add(line[-1])
            
            if(line[-1] in rhs_vars):
                rhs_vars.discard(line[-1])

        if line[0]=="if":
            if isidentifier(line[1]):
                rhs_vars.add(line[1])

    # collect dead vars set
    dead_vars = all_vars-rhs_vars
    # add lines without dead vars
    final_block=[]
    for b in block:
        line=b.copy()
        if (line[0]=="=") and (line[-1] in dead_vars):
            continue
        else:
            final_block.append(line)
    if(num_lines == len(final_block)):
        return final_block
    return dead_code_elimination(final_block)

blockno=1
updated_block=[]
original_block=[]
# Iterate over the basic blocks and locally optimize
for block in basicblocks:
    flag1=1
    flag2=1
    original_block.extend(block)
    const_folded_block, flag1 = constant_folding(block)
    const_propogated_block=[]
    i=0
    # Running folding after propagation till convergence
    while int(flag1) or int(flag2):
        const_propogated_block,flag1= constant_propagation(const_folded_block,const_propogated_block)
        const_folded_block,flag2 = constant_folding(const_propogated_block,const_folded_block)
    
    #print("\n\n-----After Constant Folding and Propogation for Basic Block",blockno,"-----")
    #for line in const_folded_block:
    #    print("\t".join(line))

    copy_propogated_block=copy_propagation(const_folded_block)
    #print("\n\n-----After Copy Propogation for Basic Block",blockno,"-----")
    #for line in copy_propogated_block:
    #    print("\t".join(line))

    updated_block.extend(copy_propogated_block)
    blockno+=1

dead_code_eliminated=dead_code_elimination(updated_block)
#print("\n\n-----After Dead Code Elimination-----")
print("\t\t FINAL OPTIMIZED INTERMEDIATE CODE\n")
print("\t\t op\targ1\targ2\tresult")
print("\t\t -----------------------------")
for line in dead_code_eliminated:
    print("\t\t","\t".join(line))
    
    