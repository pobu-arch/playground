#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include<time.h>

struct node   //字典树的节点定义
{
    char symbol; //symbol代表该节点存储的字符，如果值为0则该节点为空
    char *meaning; //指向单词含义字符串的指针
    node **number; //指向数字字符结点指针的指针
};

node *head=NULL;   //字典树头节点指针
node *current=NULL; //遍历字典树使用的指针
node* p=NULL;  //临时指针P
int* test=NULL; //辅助数组指针
double t1,t2,t3;      //定时器
char *num="0123456789"; //能够识别的数字字符
long long int readin_counter=0,aux_counter=0,test_counter=0; //计数器
long long int readin_char_counter=0,tree_char_counter=0,meaning_counter=0;
long long int node_counter=0;
long long int size_counter=0;
long long int seed=303;

void recursive_free(node *p)  //递归释放内存
{    
        if(p==NULL)    //当结点为空时返回
            return ;
        if(p->meaning!=NULL)
          free(p->meaning);   //释放保存单词含义的字符串
        if(p->number!=NULL)
        {
           int i=0;
           for(;i<10;i++)
              recursive_free(*((p->number)+i));  
           free(p->number);   //释放数字字符指针数组
        }
        free(p);       //释放整个结点
}

inline void* Malloc(const size_t temp)  
{
    void *p=malloc(temp);
    if(p!=NULL)
      return p;
    else   //封装过的malloc，当无法再分配内存时进行内存的递归释放
      {
         printf("内存耗尽，开始摧毁字典树...\n");
		 t1=(double)clock()/CLOCKS_PER_SEC;
         recursive_free(head);
         t2=(double)clock()/CLOCKS_PER_SEC;
         printf("释放耗时%lfs",t2-t1);
         exit(0);
      }
}

inline void init(node **p)  //节点初始化
{
        (*p)->symbol=0;
        (*p)->meaning=NULL;
        (*p)->number=NULL;
}

inline void insert(const char ch,node* current)
{
   current->symbol=ch;   //节点字符值的插入
}

void construct(const char ch)
{
      if(current->number==NULL)
       {
           current->number=(node**)Malloc(sizeof(node*)*10);
           int i=0;
           for(;i<10;i++)
           *(current->number+i)=NULL;
        }        
      else{};
       
       if(*(current->number+ch-num[0])==NULL)
         {
           *((current->number)+ch-num[0])=(node*)Malloc(sizeof(node));
           current=*(current->number+ch-num[0]);
           init(&current);
           insert(ch,current);
          }
        else current=*((current->number)+ch-num[0]);       
}

short int find(char *s)  //查找函数
{
    current=head;
    while(*s!='\0')
      {
         p=*(current->number+(*s)-num[0]);
         if(p!=NULL)
               {
                 current=p;
                 s++;
                 continue;
               }
        else return 1;
      }
   if(current->meaning!=NULL)
       return 0;
   else return 1;               
}

void statistic(node *p)
{
    if(p==NULL)
            return ;
    else
      {
        node_counter++;
        size_counter+=(long long int)sizeof(*p);
      }
    
    if(p->meaning!=NULL)
          {
            meaning_counter++;
          }         
    if(p->symbol!=0)
          tree_char_counter++;
    if(p->number!=NULL)
       {
              int i=0;
           for(;i<10;i++)
              statistic(*((p->number)+i));
           size_counter+=(long long int)sizeof(p->number);
           return ;
       }
    return ;
}

void aux()
{    
    t1=(double)clock()/CLOCKS_PER_SEC;
    test=(int *)Malloc(sizeof(int)*readin_counter);
    while(aux_counter!=readin_counter)
    {
        test[aux_counter]=seed;
        seed=seed*16807%2147483647;
        aux_counter++;
    }
    t2=(double)clock()/CLOCKS_PER_SEC;
    printf("辅助数组构建耗时 = %lfs",t2-t1);
}

int main()
{  
    freopen("D:\\Register\\test.txt","r",stdin);
    
    char first[30];
    char second[300];
    
    head=(node*)Malloc(sizeof(node));
    init(&head);
    
    
    t1=(double)clock()/CLOCKS_PER_SEC;
    while(scanf("%s",first)!=EOF)
     {
        current=head;
        readin_char_counter+=strlen(first);
        gets(second);
        readin_counter++;
        char* str=first;        
        {
          int i=0;
          while(str[i]!='\0')
            {      
              construct(first[i]);
              i++;
            }
           if(current->meaning!=NULL)
             {
                printf("单词重复！");
                exit(0);
              }
         else
            {    
               current->meaning=(char *)Malloc(strlen(second)+1);
                 strcpy(current->meaning,second);
             }            
         }    
       }       
     
    t2=(double)clock()/CLOCKS_PER_SEC;
    printf("I\O与字典树条目构建耗时 = %lfs",t2-t1);
    
    freopen("CON","r",stdin);    
    char readin[30];
    
    //aux(); //生成辅助数组
    int temp=1;
    t1=(double)clock()/CLOCKS_PER_SEC;
    while(temp--)
    {
        node_counter=0;
        size_counter=0;
        meaning_counter=0;
        tree_char_counter=0;
        statistic(head); //打印统计信息
    }    
    t2=(double)clock()/CLOCKS_PER_SEC;
    printf("耗时 = %lfs",t2-t1);
    printf("输入条目总数为%lld,字典树包含%lld个条目",readin_counter,meaning_counter);
    printf("输入字符总数为%lld,字典树包含%lld个字符,%lld个节点",readin_char_counter,tree_char_counter,node_counter);
    printf("字典树大小%lldMB,字符压缩百分比%.2lf%%",size_counter/1024/1024,(double)tree_char_counter/readin_char_counter*100);
    printf("节省内存%lldMB",(readin_char_counter-size_counter)/1024/1024);
    t3=0;
    
   /*while(test_counter<=readin_counter)
    {
      sprintf(readin,"%d",seed);
      seed=seed * 16807 % 2147483647;
      t1=(double)clock()/CLOCKS_PER_SEC;
      switch(find(readin))
       {
        case 0:break;
        case 1:printf("%s单词未找到\n",readin);break;
       }
      test_counter++;
      t2=(double)clock()/CLOCKS_PER_SEC;
      t3+=t2-t1;
    }
    free(test);
    printf("耗时 = %lfs\n",t3);*/
    
    getchar();
	return 0;
}
