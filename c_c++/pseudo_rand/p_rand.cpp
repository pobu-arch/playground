#include<iostream>
#include<fstream>
#include<string>
#include<stack>
#include<queue>
#include<vector>
#include<algorithm>
#include<deque>
#include<set>
#include<map>
#include<cstring>
#include<cstdio>
#include<cmath>
#include<cstdlib>
#include<cctype>
#include<time.h>
#include<cassert>
using namespace std;

#define scale 18000000
#define modulous 2147483647

struct word{
	long long int pseudo_chi;
	long long int pseudo_eng;
	bool operator <(const word& b) const
	{
		return pseudo_chi < b.pseudo_chi;
	}
};

int main()
{  
	ofstream fout;
	fout.open("D:\\Register\\test.txt");
	ios::sync_with_stdio(false);
	vector<word> dic;
	multiset<long long int> repeat;
	long long int seed=rand();
	word temp;

	double t1,t2;

	t1=(double)clock()/CLOCKS_PER_SEC;

	for(int i=0;i<scale;i++)
	{
		if(repeat.find(seed)!=repeat.end())
		{
			printf("repeat!\n");
			exit(0);
		}
		else if( (double)i/scale*100 == floor((double)i/scale*100))
		{
			cout<<"generating "<<(double)i/scale*100<<" persent(s)"<<endl;
		}
		repeat.insert(seed);       
		temp.pseudo_chi=seed;
		temp.pseudo_eng=seed*16807 % modulous;
		dic.push_back(temp);        
		seed=temp.pseudo_eng;

	}

	t2=(double)clock()/CLOCKS_PER_SEC;

	cout<<"generation timing = "<<t2-t1<<endl;

	t1=(double)clock()/CLOCKS_PER_SEC;
	sort(dic.begin(),dic.end());
	t2=(double)clock()/CLOCKS_PER_SEC;
	cout<<"sortion timing = "<<t2-t1<<endl;

	t1=(double)clock()/CLOCKS_PER_SEC;
	for(int i=0;i<scale;i++)
	{
		if( (double)i/scale*100 == floor((double)i/scale*100))
		{
			cout<<"writing "<<(double)i/scale*100<<" persent(s)"<<endl;
		}
		fout<< dic.at(i).pseudo_chi <<" "<<dic.at(i).pseudo_eng<<endl;
	}
	t2=(double)clock()/CLOCKS_PER_SEC;
	cout<<"writing timing = "<<t2-t1<<endl;

	return 0;
}
