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

