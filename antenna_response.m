function R=antenna_response(Net,R,n1,intend)
    N=Net.node(n1).directivity.N;
    w=Net.node(n1).directivity.weights;
for i=1:size(intend,1);
    n2=intend(i,1);
    ang=Net.angles{n1,n2};
    AF=gen_AF(N,ang(1));
    R_temp=w'*AF;
    R(n1,n2)=abs(R_temp);
end
