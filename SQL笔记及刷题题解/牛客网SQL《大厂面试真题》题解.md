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

