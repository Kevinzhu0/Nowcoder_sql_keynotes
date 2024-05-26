# 01 某音短视频

## SQL156 各个视频的平均完播率

![image-20240519130623381](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240519130623381.png)

**计算2021年里有播放记录的每个视频的完播率(结果保留三位小数)，并按完播率降序排序**

### 梳理思路

1、根据题目意思，完播率是指完成播放的次数占总播放次数的比例；那么，要计算出最终结果，就得分别求出完成播放的次数和总播放次数；且题目提示：结束观看时间与开始播放时间的差>=视频时长即为完成播放的评判指标；

2、题目要求被查询出的字段为video_id&avg_comp_play_rate；

3、首先求出每个视频的总播放次数；然后求出对应视频的完成播放的次数；根据公式计算即能得出完播率；

4、注意：根据题目意思，计算2021年里有播放记录的每个视频的完播率；添加筛选条件“where year(tb_user_video_log .start_time)=2021”；



### 组合代码

~~~mysql
select rt3.video_id video_id
,round(play_count/sumplay_count,3) avg_comp_play_rate
from
(
    select rt2.video_id video_id
    ,sum(count) play_count
    from
    (
        select rt1.video_id video_id
        ,(case when play_duration>=duration then 1 else 0 end) count
        from
        (
            select tb_user_video_log.video_id video_id
            ,(end_time-start_time) play_duration
            ,duration
            from tb_user_video_log join tb_video_info on tb_user_video_log.video_id=tb_video_info.video_id
            where year(tb_user_video_log.start_time)=2021
            group by 1,2
            order by 1
        ) rt1
    ) rt2
    group by 1
) rt3
join
(
    select video_id
    ,count(*) sumplay_count
    from tb_user_video_log
    where year(tb_user_video_log.start_time)=2021
    group by 1
    order by 1
) rt4 on rt3.video_id=rt4.video_id
order by avg_comp_play_rate desc
~~~



## **SQL157** **平均播放进度大于60%的视频类别**

![image-20240520232002862](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240520232002862.png)

**计算各类视频的平均播放进度，将进度大于60%的类别输出**

### 梳理思路

1、首先梳理清楚播放进度公式：播放进度=播放时长/视频时长*100%，当播放时长大于视频时长时，播放进度均记为100%；结果保留两位小数，并按**播放进度**倒序排序；

2、分别计算播放时长和查询出视频时长；

3、播放时长=timestampdiff(second, start_time, end_time)；用户视频互动表tb_user_video_log和短视频信息表tb_video_info；连接键为video_id，同时增加字段：计算各类视频的平均播放进度avg_play_progress,使用case...when...then...else...end函数，将视频的播放时长>视频时长的视频进度记为1，否则通过计算公式：else timestampdiff(second, start_time, end_time)/duration end)*100,2),'%')计算平均播放进度；以视频的类别标签tag作为分组聚合的标签

4、最后再新建一个外查询，添加where筛选条件：将平均播放进度大于60%的类别输出where replace(avg_play_progress,'%','') > 60；查询出题目要求的字段：a.tag, avg_play_progress；

5、最后添加一个排序规则：order by avg_play_progress DESC；以平均播放进度降序排序；

### 组合代码

~~~mysql
select a.tag
, avg_play_progress
from 
(
    select tag
    ,concat(round(avg(case when timestampdiff(second, start_time, end_time) >= duration then 1 else timestampdiff(second, start_time, end_time)/duration end)*100,2),'%') avg_play_progress
    from tb_user_video_log t1
    join tb_video_info t2
    on t1.video_id=t2.video_id
    group by tag
) a
where replace(avg_play_progress,'%','') > 60
order by avg_play_progress DESC
~~~



## **SQL158** **每类视频近一个月的转发量/率**

### ![image-20240522100512230](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240522100512230.png)

### 梳理思路

**统计在有用户互动的最近一个月(按包含当天在内的近30天算，比如10月31日的近30天为10.2--10.31之间的数据)中，每类视频的转发量和转发率(保留3位小数)**

注：转发率=转发量/播放量

1、分别计算视频的播放量和转发量；视频播放量：count(video_log.video_id)、视频转发量：sum(video_log.if_retweet) retweet_count；

2、筛选条件：datediff #筛选近30天的用户互动记录

(

  date

  (

​    (select max(start_time) from tb_user_video_log)

  )

  ,date(start_time)

) <= 29 ；

3、连接两表的连接键为video_id；

4、聚合依据为video_info.tag；

5、以retweet_rate为排序依据，降序排序；

6、计算转发率的公式为：round(sum(video_log.if_retweet)/count(video_log.video_id),3) retweet_rate；



### 组合代码

~~~mysql
select video_info.tag
,sum(video_log.if_retweet) retweet_count
,round(sum(video_log.if_retweet)/count(video_log.video_id),3) retweet_rate
from tb_user_video_log video_log join tb_video_info video_info on
video_log.video_id=video_info.video_id
where datediff #筛选近30天的用户互动记录
(
    date
    (
        (select max(start_time) from tb_user_video_log)
    )
    ,date(start_time)
) <= 29
group by 1
order by retweet_rate desc
~~~



## **SQL159** **每个创作者每月的涨粉率及截止当前的总粉丝量**

![image-20240522110044530](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240522110044530.png)

**题目：计算2021年里每个创作者每月的涨粉率及截至当月的总粉丝量**

涨粉率=（加粉量-掉粉量）/ 播放量，结果按创作者ID、总粉丝量升序排序；

if_follow-是否关注字段的解释：if_follow为1表示用户观看视频中关注了视频创作者，为0表示此次互动前后关注状态为发生变化，为2表示本次观看过程中取消了关注；

### 梳理思路

**本题的核心是计算涨粉数量**

1、目标字段：author创作者、month每个月月份、fans_growth_rate每个月的涨粉率和截止当月的总粉丝量total_fans;

2、筛选条件：year(start_time)=2021 and year(end_time),或者通过新增一个年份字段,然后作为连接字段,或者；“计算2021年里每个创作者每月的涨粉率及截至当月的总粉丝量”；还需要筛选if_follow字段是0、1、2；

3、筛选if_follow，case when if_follow=2 then -1 else if_follow end;

4、用date_format(start_time，'%Y-%m') ;



### 组合代码

~~~mysql
with
    main as(
        #统计每个用户的播放量、加粉量、掉粉量
        select 
            author,
            mid(start_time,1,7) as month,
            count(start_time) as b,
            count(if(if_follow = 1, 1, null)) as follow_add,
            count(if(if_follow = 2, 1, null)) as follow_sub
        from tb_user_video_log a, tb_video_info b
        where a.video_id = b.video_id
        and year(start_time) = 2021
        group by author,month
    )
#计算2021年里每个创作者每月的涨粉率及截止当月的总粉丝量
select 
    author,
    month,
    round((follow_add-follow_sub)/b ,3) as fans_growth_rate,
    sum(follow_add-follow_sub) over(partition by author order by month) as total_fans
from main
order by author,total_fans
~~~



## **SQL160** **国庆期间每类视频点赞量和转发量**

![image-20240523235951770](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240523235951770.png)

**统计2021年国庆头3天每类视频每天的近一周总点赞量和一周内最大单天转发量，结果按视频类别降序、日期升序排序。假设数据库中数据足够多，至少每个类别下国庆头3天及之前一周的每天都有播放记录。**

### 组合代码

~~~mysql
select *
from
(
    select tag
    ,date as dt
    ,sum(like_cnt) over (partition by tag order by date rows between 6 preceding and current row) as sum_like_cnt_7d
    ,max(retweet_cnt) over (partition by tag order by date rows between 6 preceding and current row) as max_retweet_cnt_7d
    from 
    (
        select info.tag
        ,date_format(log.start_time,'%Y-%m-%d') as date
        ,sum(if_like) as like_cnt
        ,sum(if_retweet) as retweet_cnt
        from tb_user_video_log log
        join tb_video_info info
        on log.video_id = info.video_id
        group by info.tag, date_format(log.start_time,'%Y-%m-%d')
    ) rt1
) rt2
where dt in ('2021-10-01', '2021-10-02', '2021-10-03')
order by tag desc, dt asc
~~~

### 梳理代码逻辑思路

1、**看到这题，“近一周总点赞量和一周内最大单天转发量”--由此联想到窗口函数“order by date rows between 6 preceding and current row”**；但是，现有的表格中只有单天的点赞量和用户在当天的转发量，所以应使用聚合依据和聚合函数，以视频类别和log.start_time日期为group by分组聚合的依据；子查询中通过计算字段和聚合字段已经查询出了每个视频种类单天的总点赞量和单天的 总转发量便于外查询再次计算周总点赞量和周最大单天转发量；

2、新建外查询，外查询中开聚合窗口函数并且以tag(视频类别)为partition by的分组聚合字段，以date升序排序，**rows between 6 preceding and current row**计算以今天为基准，今天以及前六天(共7天时间的总点赞量和最大单天转发量)；

3、最后再建一个外查询，为了筛选出国庆前三天每类视频每天的近一周总点赞量和一周内最大单天转发量；添加where筛选条件：”where dt in ('2021-10-01', '2021-10-02', '2021-10-03')“；并且结果按视频类别降序、日期升序排序order by tag desc, dt asc；



## **SQL161** **近一个月发布的视频中热度最高的top3视频**

![image-20240524165720075](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240524165720075.png)

**找出近一个月发布的视频中热度最高的top3视频**

### 梳理逻辑思路

1、**热度最高的top3视频**说明需要按照热度进行排名，如果视频热度不会有重复的，那么函数row_number()over()比较适合:可以输出唯一且连续的排名，最后通过筛选出前三名即可//limit 3；

2、如果要筛选那么就得先计算出热度字段；根据题目要求：

- 热度=(a*视频完播率+b*点赞数+c*评论数+d*转发数)*新鲜度==(a*视频完播率+b*点赞数+c*评论数+d*转发数)/(最近无播放天数+1)；

- 新鲜度=1/(最近无播放天数+1)；
- 当前配置的参数a,b,c,d分别为100、5、3、2。
- 最近播放日期以**end_time-结束观看时间**为准，假设为T，则最近一个月按[T-29, T]闭区间统计；题目要求：最近播放日期为2021-10-03，以这个日期为开始日期；
- 结果中热度保留为**整数**，并按热度**降序**排序。

1. 查询1：
   1. 目标字段：video_id,完播率(完成播放次数/被播放的总次数)，最近一个月总的的被点赞数，最近一个月总的的被评论数，最近一个月总的转发数，最近一个月无播放的总天数，最近无播放天数；
   2. 库表来源：用户-视频互动表tb_user_video_log&短视频信息表tb_video_info;
   3. 连接关系：以video_id为连接键连接互动表和短视频信息表；
      1. 筛选条件：筛选近一个月发布的视频中的用户-视频互动表数据：where DATEDIFF((select max(end_time) from tb_user_video_log), info.release_time) <= 29;筛选完成播放的数据 : sum(case when timestampdiff(second, start_time, end_time) >= duration then 1 else 0 end);筛选出有评论的记录count(comment_id) comment_cnt;筛选出最近无播放天数：DATEDIFF((select max(end_time) from tb_user_video_log), max(end_time)) non_play_cnt，其中select max(end_time) from tb_user_video_log 是取整个表格中最近的日期，而max(end_time)后是有group by video_id的，取的是每个视频的最近日期。
   4. 聚合依据：video_id；

2. 查询2：
   1. 目标字段：video_id视频id，,round((100*play_rate+5*like_cnt+3*comment_cnt+2*retweet_cnt)/(non_play_cnt+1),0) hot_index 热度；
   2. 库表来源：查询1；
   3. 连接关系：无;
   4. 筛选条件：无;
   5. 聚合依据：无;
   6. order by hot_index desc;
   7. limit 3;



### 组合代码

~~~mysql
select rt1.video_id
,round((100*play_rate+5*like_cnt+3*comment_cnt+2*retweet_cnt)/(non_play_cnt+1),0) hot_index
from
(
    select log.video_id video_id
    ,round(sum(case when timestampdiff(second, start_time, end_time) >= duration then 1 else 0 end)/count(log.video_id),1) play_rate
    ,sum(if_like) like_cnt
    ,count(comment_id) comment_cnt
    ,sum(if_retweet) retweet_cnt
    ,DATEDIFF((select max(end_time) from tb_user_video_log), max(end_time)) non_play_cnt
    from tb_user_video_log log join tb_video_info info on
    log.video_id=info.video_id
    where DATEDIFF((select max(end_time) from tb_user_video_log), info.release_time) <= 29
    group by 1
) rt1
order by hot_index desc
limit 3
~~~



# 02 用户增长场景（某度信息流）	

## **SQL162** **2021年11月每天的人均浏览文章时长**

![image-20240524184228919](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240524184228919.png)

**场景逻辑说明：**artical_id-文章ID**代表用户浏览的文章的ID，**artical_id-文章ID**为**0**表示用户在非文章内容页（比如App内的列表页、活动页等）。

**问题**：统计2021年11月每天的人均浏览文章时长（秒数），结果保留1位小数，并按时长由短到长排序。

### 梳理代码逻辑思路

1、目标字段：date_format(in_time,'%Y-%m-%d') dt,人均浏览文章时长(秒数)，库表来源：用户行为日志表tb_user_log；

2、筛选条件为artical_id!=0和month(in_time)=11 and month(out_time)=11;

3、聚合依据：date_format(in_time,'%Y-%m-%d') dt；

1. 查询1
   1. 目标字段：date_format(in_time,'%Y-%m-%d') dt 日期，去重用户id: count( distinct uid) cnt用户人数，sum(timestampdiff(second, in_time, out_time)) duration 浏览文章总时长；
   2. 库表来源：tb_user_log；
   3. 筛选条件：where artical_id!=0 and month(in_time)=11 and month(out_time)=11；
   4. 聚合依据：date_format(in_time,'%Y-%m-%d') dt；
2. 查询2
   1. 目标字段：dt,round(duration/cnt,1) avg_viiew_len_sec 人均浏览时长；
   2. 库表来源：查询1；
   3. 连接关系：无；
   4. 筛选条件：无；
   5. 聚合依据：无；
   6. order by: order by avg_viiew_len_sec 升序排序；



### 组合代码

~~~mysql
select dt
,round(duration/cnt,1) avg_viiew_len_sec
from
(
    select date_format(in_time,'%Y-%m-%d') dt
    ,count( distinct uid) cnt
    ,sum(timestampdiff(second, in_time, out_time)) duration
    from tb_user_log
    where artical_id!=0 and month(in_time)=11 and month(out_time)=11
    group by 1
) rt1
order by avg_viiew_len_sec
~~~



## **SQL163** **每篇文章同一时刻最大在看人数**

![image-20240524192435369](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240524192435369.png)

**问题**：统计每篇文章同一时刻最大在看人数，如果同一时刻有进入也有离开时，先记录用户数增加再记录减少，结果按最大人数降序。

### 梳理代码逻辑和思路

1. 将用户的进入时间单独拎出来，同时记为1；离开时间单独拎出来，同时记为-1，这样就聚合这两个表，按照时间排序，意思就是：进去一个加1，离开一个减1；
2. 然后利用窗口函数对计数（1或者-1）求累计和，因为题目规定：同一时间有就有出的话先算进来的后算出去的，所以排序的时候就要看好了先按时间排序，再按计数排序；
3. 然后再在每个分组里面去求最大max()的累积和就是最多同时在线的人数了；
4. union和union all的区别就是：UNION` 会去除重复的行。如果要包含重复的行，可以使用 `UNION ALL；



### 组合代码

~~~mysql
select artical_id, max(uv) as max_uv
from 
(
    select artical_id
    ,sum(tag) over (partition by artical_id order by dt,tag desc) as uv
    from 
    (
        select artical_id, uid, in_time as dt, 1 as tag
        from tb_user_log
        where artical_id != 0
        union
        select artical_id, uid, out_time as dt, -1 as tag
        from tb_user_log
        where artical_id != 0
    ) as t1
) as t2
group by artical_id
order by max_uv desc
~~~



## **SQL164** **2021年11月每天新用户的次日留存率**

![image-20240526162615368](C:\Users\victory\AppData\Roaming\Typora\typora-user-images\image-20240526162615368.png)

**统计2021年11月每天新用户的次日留存率(保留2位小数)**

注：

- 次日留存率为当天新增的用户数中第二天又活跃了的用户数占比。
- 如果**in_time-进入时间**和**out_time-离开时间**跨天了，在两天里都记为该用户活跃过，结果按日期升序。



### 梳理逻辑思路

1、根据留存率的计算公式：第一天登录过的新用户在第二天又登录的数量/第一天登陆过的新用户数量；分别计算这两个数量，套进公式里计算得出结果；

2、目标字段：时间字段dt，uv_left_rate留存率字段；

3、聚合依据：时间字段dt；

4、筛选条件：2021年11月--where date_format(a.dt,"%Y-%m")='2021-11'；

5、库表来源：用户行为日志表tb_user_log；

1. 查询1：先计算出每个用户首次活跃日期
   1. 以uid为聚合依据
   2. 计算每个用户登录的日期的最小值：min(date(in_time)) dt，即首次登录日期；
2. 查询2：计算每个用户的全部活跃日期
   1. 将in_time&out_time两个时间的uid登录的用户的记录分开并使用union将表与表之间的数据进行上下拼接
   2. 将查询1&2通过左连接left join连接起来；左边主表是用户第一次登录的记录、右边表如果不为none则为符合题目要求的次日登录的用户的记录，连接键为uid和a.dt=date_sub(b.dt,INTERVAL 1 day) ：表1的日期=表2日期减一天；
3. 添加where筛选条件
   1. where date_format(a.dt,'%Y-%m')='2021-11'
4. 聚合依据group by
   1. group by a.dt
5. 新建外查询，计算题目要求的字段：次日留存率，保留2位小数
   1. round(count(b.uid)/ count(a.uid),2) as uv_left_rate;



###  组合代码

~~~mysql
select a.dt
,round(count(b.uid)/ count(a.uid),2) as uv_left_rate
from 
(
    select uid
    ,min(date(in_time)) dt
    from tb_user_log
    group by uid
) as a
left join   
(
    select uid 
    ,date(in_time) dt
    from tb_user_log
    union
    select uid 
    ,date(out_time)
    from tb_user_log
) as b
on a.uid=b.uid
and a.dt=date_sub(b.dt,INTERVAL 1 day)      
where date_format(a.dt,"%Y-%m")='2021-11'
group by a.dt
~~~



