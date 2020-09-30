def sum3(A,sum):
    A.sort()#O(nlogn)
    n = len(A)
    q = len(A) - 1
    for i in range (0, n - 2):
        p = i + 1
        q = n - 1

        while(p < q):
            if A[i] + A[p] + A[q] == sum:
                print(A[i], '+', A[p], '+', A[q], '=', sum)
                return True
            p += 1
            q -= 1
    return False
        

def count_inversions(A):
    B = []
    return mergeSort(A, B, 0 , len(A) - 1)

def mergeSort(A, B, left, right):
    invCnt = 0
    if (right > left):
        mid = right / 2
        invCnt += mergeSort(A, B, left, mid)
        invCnt += mergeSort(A, B, mid+1, right)
        invCnt += merge(A, B, left, mid, right)
    return invCnt

def merge(A, B, left, mid, right):
    invCnt = 0
    i = left    #Left subarray iterator
    j = mid     #Right subarray iterator
    k = left    #Iterator for merged array

    while((i <= mid - 1) and (j <= right)):
        #Non inversion
        if A[i] <= A[j]:
            B[k] = A[i]
            k += 1
            i += 1

        #Inversion
        else:
            B[k] = A[j]
            k += 1
            j += 1
            invCnt += mid - i

    #Copy rest of elements
    while(i <= mid -1):
        B[k] = A[i]
        k += 1
        i += 1
    while(j <= right):
        B[k] = A[j]
        k += 1
        j += 1

    #Copy merged array
    for x in range(left, right + 1):
        A[x] = B[x]

    return invCnt


def findMissingNum(A):
    n = len(A)
    sum = (n * (n+1)) / 2
    A_sum = 0
    for i in range(0, n):
        A_sum += A[i]
    return sum - A_sum

def findMissingNum_XOR(A):
    n = len(A)
    XOR = A[0]
    for i in range(1, n):
        XOR ^= A[i]
    for i in range(0, n+1):
        XOR ^= i
    return XOR

if __name__ == "__main__":
    A=[-4,-1,0,0,0,1,2,3]

    print(f'3 sum for A: {A}: {sum3(A,0)}')

    B = [0,1,2,3,4,5,6,7,9,10]

    print(f'Find missng num for B: {B}: {findMissingNum(B)}')
    print(f'Find missng num XOR for B: {B}: {findMissingNum_XOR(B)}')

    C = [0,1,2,3,4,5,6,7,8,9,10]
    D = [10,9,8,7,6,5,4,3,2,1,0]
    E = [2,4,1,3,5]
    
    print(f'Number of inversions for {C}: {count_inversions(C)}')
    print(f'Number of inversions for {D}: {count_inversions(D)}')
    print(f'Number of inversions for {E}: {count_inversions(E)}')