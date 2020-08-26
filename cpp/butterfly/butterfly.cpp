#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cassert>
using namespace std;

typedef long long int int64;
struct raw
{
    float price_open;
    float price_high;
    float price_low;
    float price_close;
    float volume;
    long long int time;
};

int test_fp(int a)
{
    return a + 1;
}

vector<float> calc_EMA(const vector<float>& input, const float& alpha)
{
    vector<float> output;
    output.push_back(input.at(0));
    for(int64 index = 1; index < input.size(); index++)
    {
        output.push_back(alpha * input.at(index) + (1 - alpha) * output.at(index - 1));
    }
    return output;
}

vector<float> calc_RSI(const vector<raw>& raw, const int64& length)
{
    vector<float> input;
    vector<float> input_diff;
    vector<float> up;
    vector<float> down;
    vector<float> rs;
    vector<float> rsi;

    for(int64 index = 0; index < raw.size(); index++)
    {
        input.push_back(raw.at(index).price_close);
    }

    for(int64 index = 1; index < input.size(); index++)
    {
        input_diff.push_back(input.at(index) - input.at(index-1));
    }

    up.push_back(0);
    for(int64 index = 0; index < input_diff.size(); index++)
    {
        if(input_diff.at(index) < 0)
        {
            up.push_back(0);
        }
        else
        {
            up.push_back(input_diff.at(index));
        }
    }

    down.push_back(0);
    for(int64 index = 0; index < input_diff.size(); index++)
    {
        if(input_diff.at(index) > 0)
        {
            down.push_back(0);
        }
        else
        {
            //down.push_back(abs(input_diff.at(index)));
        }
    }

    vector<float> up_ema   = calc_EMA(up,   1.0 /   length);
    vector<float> down_ema = calc_EMA(down, 1.0 / length);

    assert(up.size() == down.size());
    assert(up.size() == up_ema.size());
    assert(up_ema.size() == down_ema.size());

    for(int64 index = 0; index < down_ema.size(); index++)
    {
        if(down_ema.at(index) == 0)
        {
            rs.push_back(up_ema.at(index) / -1.0);
        }
        else
        {
            rs.push_back(up_ema.at(index) / down_ema.at(index));
        }
    }

    for(int64 index = 0; index < rs.size(); index++)
    {
        if(rs.at(index) > 0)
        {
            rsi.push_back(100 - 100/(1.0 + rs.at(index)));
        }
        else
        {
            if(rs.at(index) == 0)
            {
                rsi.push_back(1);
            }
            else
            {
                rsi.push_back(100);
            }
        }
    }
    return rsi;
}

vector<float> calc_StochRSI(const vector<raw>& raw, const int64& length)
{
    
}

vector<raw> digest_rawdata_input(const char* file_path)
{
    ifstream raw_ifs(file_path);
    vector<raw> raw_vector;
    
    raw raw_temp;
    while(raw_ifs >> raw_temp.price_open >> raw_temp.price_high >> raw_temp.price_low >> raw_temp.price_close >> raw_temp.volume >> raw_temp.time)
    {
        raw_vector.push_back(raw_temp);
    }
    raw_ifs.close();
    return raw_vector;
}

vector<raw> generate_K_mins(const vector<raw>& raw_vector, int64 k)
{
    vector<raw> result;
    raw raw_temp;
    
    for(int64 index = 0; index < raw_vector.size(); index+=k)
    {
        raw_temp.price_open  = raw_vector.at(index).price_open;
        raw_temp.price_close = raw_vector.at((index + (k - 1)) % raw_vector.size()).price_close;
        raw_temp.time        = raw_vector.at((index + (k - 1)) % raw_vector.size()).time;
        
        raw_temp.price_high  = 0;
        raw_temp.price_low   = 99999;
        raw_temp.volume      = 0;
        for(int64 step = 0; step < k; step++)
        {
            if(raw_temp.price_high < raw_vector.at((index + step) % raw_vector.size()).price_high)
            {
                raw_temp.price_high = raw_vector.at((index + step) % raw_vector.size()).price_high;
            }
            if(raw_temp.price_low > raw_vector.at((index + step) % raw_vector.size()).price_low)
            {
                raw_temp.price_low = raw_vector.at((index + step) % raw_vector.size()).price_low;
            }
            raw_temp.volume += raw_vector.at((index + step) % raw_vector.size()).volume;
        }
        result.push_back(raw_temp);
    }

    return result;
}

int main(int argc, char** argv)
{
    /*
    vector<raw> raw_vector = digest_rawdata_input("raw.txt");    
    vector<raw> k3         = generate_K_mins(raw_vector, 3);
    vector<raw> k5         = generate_K_mins(raw_vector, 5);
    vector<raw> k15        = generate_K_mins(raw_vector, 15);

    vector<raw> temp;
    for(int index = 0; index < 9; index++)
    {
        temp.push_back(k15.at(index));
    }

    vector<float> rsi15    = calc_RSI(temp, 6);
    */

    printf("The total num of arguments is %d\n", argc);

    for(int i =0; i < argc; i++)
        printf("The first argument is %s\n", argv[i]);
    
    int(*p)(int) = test_fp;
    printf("pointer is %p\n", p);
}