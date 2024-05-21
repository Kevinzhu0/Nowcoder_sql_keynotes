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



