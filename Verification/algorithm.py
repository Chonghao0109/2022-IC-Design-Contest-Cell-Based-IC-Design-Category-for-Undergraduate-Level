
size = 8
print('Start Test size:',size)

P = [0,1,2,3,4,5,6,7]


print(P)

counter = 8
p = 0
while(1):

	# Step 1.
	#Find swap_position1
	swap_position1 = 0
	for i in range(0,size-1):
		if(P[i] < P[i+1]):
			swap_position1 = i


	# Step 2.
	#Find swap_position1
	swap_position2 = size - 1
	value = size - 1
	for i in range(0,size):
		if(i>swap_position1): 
			if( P[i] > P[swap_position1] and P[i] <= value):
				swap_position2 = i
				value = P[swap_position2]
	# swap 
	reg_P = []
	for i in range(0,size):
		if(i==swap_position1):
			reg_P.append(P[swap_position2])
		elif(i==swap_position2):
			reg_P.append(P[swap_position1])
		else:
			reg_P.append(P[i])
	
	# Step 3.
	Next_P=[]
	for i in range(0,size): 
		if(i>swap_position1):
			Next_P.append(reg_P[ size - (i-swap_position1-1) -1 ])
		else:
			Next_P.append(reg_P[i])



	for i in range(0,size):
		if(P[i] != Next_P[i]):
			counter +=1


	P = Next_P
	print(p,' ',P,'c:',counter)
	p=p+1


	if(P==[7,6,5,4,3,2,1,0]):
		print('Counter',counter)
		break

