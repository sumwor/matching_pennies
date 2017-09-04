
def iterChoice(choiceList, seq):
    #iteration the choice list and find the left choices and right choices
    N = len(seq)
    leftChoice=0
    rightChoice=0
    k=0
    for i in range(len(choiceList)-N):
        if choiceList[i:i+N] == seq:
            if choiceList[i+N] ==0:
                leftChoice+=1
            else:
                rightChoice+=1
                
    return leftChoice, rightChoice



c= [0, 0, 1, 0, 1, 1, 0, 1, 0, 0]

left,right = 