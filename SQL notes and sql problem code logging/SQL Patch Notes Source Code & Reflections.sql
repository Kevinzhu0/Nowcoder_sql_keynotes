select *
from test.`8月成交数据`
where 成交额>100000;

select `8月获客数据`.日期,`8月获客数据`.业务组,注册人数,戳额人数,成交人数,round(成交人数/注册人数,4) 成交率
from test.`8月获客数据`
where 注册人数>1000 and 成交人数<500

select distinct 城市,业务组
from test.`8月成交数据`
where 应收利息<100

select distinct 业务组,成交人数
from test.`8月获客数据`
where 成交人数<10

select  业务组,`8月获客数据`.成交人数
from test.`8月获客数据`
where 成交人数<10
group by 1,2

select 城市,业务组,sum(成交额),avg(成交额),max(成交额),min(成交额)
from test.`8月成交数据`
where 应收利息<100
group by 1,2

select 业务组,sum(成交人数),count(distinct `8月获客数据`.日期) 天数
from test.`8月获客数据`
where 成交人数<10
group by 1

select 业务组,sum(成交人数),count(distinct 日期) 天数
from test.`8月获客数据`
where 成交人数<10
group by 1
having sum(戳额人数)>=100

select 业务组,城市,城市等级,城市经理,sum(成交额) 成交总额
from test.`8月成交数据` join test.城市信息
on test.`8月成交数据`.城市=test.城市信息.城市名称
group by 1,2,3,4
having 成交总额>500000

# 双表单连接键
# 查询8月成交额总和大于100万的所有战区,以及它们对应的战区,战区等级和战区经理

select deal.战区,military.战区等级,military.战区经理,sum(deal.成交额) 成交总额
from test.`8月成交数据` deal join test.战区信息 military
on deal.战区=military.战区名称
group by 1,2,3
having 成交总额>1000000

#双表多连接键
#查询单日成交额曾大于一万、注册人数大于1000，且满足条件的日期内成交人数总和小于10万的所有城市，及应收利息总和，按应收利息降序排序
select deal.城市,sum(deal.应收利息) 应收利息总和,sum(customer.成交人数) 成交人数总和
from test.`8月成交数据` deal join test.`8月获客数据` customer
on deal.日期=customer.日期 and deal.业务组=customer.业务组
where deal.成交额>10000 and customer.成交人数>1000
group by 1
having 成交人数总和<100000
order by 应收利息总和 desc

#多表多连接键
#查询单日成交额曾大于1万、注册人数大于1000，且满足条件的日期内成交人数总和小于10万的所有城市及他们的城市经理
select deal.城市, city.城市经理, sum(customer.成交人数) 成交人数总和
from test.`8月成交数据` deal join test.`8月获客数据` customer
on deal.日期=customer.日期 and deal.业务组=customer.业务组
join test.城市信息 city on deal.城市=city.城市名称
where deal.成交额>10000 and customer.注册人数>1000
group by 1,2
having 成交人数总和<100000

#课后练习
#查询单日成交额曾大于10万、注册人数大于5000，
# 且对应日期内逾期金额总和小于10万的所有业务组，
# 它们在对应日期内的成交总和、注册人数总和、逾期总和、逾期率=逾期总和/成交总和(保留四位小数)，
#及它们的所属的城市、城市经理、战区、战区经理
select deal.业务组, deal.城市,city.城市经理,deal.战区,area.战区经理,
sum(deal.成交额) 成交总和,sum(customer.注册人数) 注册人数总和,sum(deal.逾期金额) 逾期总和,round(sum(deal.逾期金额)/sum(deal.成交额),4) 逾期率
from test.`8月成交数据` deal join test.`8月获客数据` customer
on deal.日期=customer.日期 and deal.业务组=customer.业务组
join test.城市信息 city
on deal.城市=city.城市名称
join test.战区信息 area
on deal.战区=area.战区名称
where deal.成交额>100000 and customer.注册人数>5000
group by  1,2,3,4,5
having 逾期总和<100000

select sum(成交额) 成交额总和
from test.`8月成交数据`
where test.`8月成交数据`.城市 in
      (
        select 城市
        from test.`8月成交数据`
        group by 1
        having sum(成交额) > 10000000
        );
#where in 相当于表连接后再筛选:left join
select sum(成交额) 成交额总和
from test.`8月成交数据` deal left join
(
     select 城市
      from test.`8月成交数据`
      group by 1
      having sum(成交额) > 10000000
) city
on deal.城市=city.城市
where city.城市 is not null

#select子查询,直接写字段
select
'8月' 月份
,sum(成交额) 总成交额
,sum(成交额)/
(
    select
    sum(成交人数)
    from test.`8月获客数据`
) 人均成交额
from test.`8月成交数据`

#from子查询;计算8月份全公司各城市的平均成交额
#目标字段：avg(各城市成交额)
#库表来源：成交数据
#连接关系：无
#筛选条件：无
#聚合依据：1、城市；2、城市&各个城市的成交额(整张表);当有两个聚合依据时需要使用子查询
#梳理思路：1、先计算出各个城市的成交额总和；2、然后基于计算出来的城市和成交额计算出平均成交额
#分段编辑：1、
# select 城市,sum(成交额) 各城市成交额
# from test.`8月成交数据`
# group by 1

# #2、
# select avg(各城市成交额)
# from
# (
#     子查询
# )
#组合代码：avg(各城市成交额)相当于sum(各城市成交额)/count(城市)
select avg(各城市成交额) 平均成交额
from
(
    select 城市,sum(成交额) 各城市成交额
    from test.`8月成交数据`
    group by 1
) deal_city

#having子查询;求出成交额大于城市平均成交额的城市以及这些城市的成交额，按成交额降序排序
select 城市,sum(成交额) 满足条件的各城市成交额
from test.`8月成交数据`
group by 1
having 满足条件的各城市成交额>
(
    select avg(各城市成交额) 平均成交额
    from
    (
        select 城市, sum(成交额) 各城市成交额
        from test.`8月成交数据`
        group by 1
    ) deal_city
)
order by 满足条件的各城市成交额 desc

#上题用select子查询;解法如下:
#目标字段:城市、城市成交额
#库表来源:8月成交数据
#连接关系:无
#筛选条件:where/having: where 城市成交额大于城市平均成交额
#聚合依据:城市；城市&城市成交额；城市平均成交额
#梳理思路:1、先计算出各城市的成交总额；2、再计算出所有城市成交额的平均值；
# 3、计算各城市的成交总额并把成交额的平均值作为一个字段写入select字段中;4、将前一步作为from后接的一张新表,加入筛选条件
#分段编辑:
#1、计算各城市的成交总额
# select 城市,sum(成交额) 成交总额
# from test.`8月成交数据`
# group by 1
# ;

#2、再计算出所有城市成交额的平均值
# select avg(成交总额) 平均成交额
# from
# (
#     子查询1
# )

#3、计算各城市成交总额并把成交额的平均值作为一个字段写入select后的字段中
# select 城市,sum(成交额) 成交总额,子查询2
# from test.`8月成交数据`
# group by 1

#4、将前一步作为from后接的一张新表，加入筛选条件
# select 城市,成交总额
# from
# (
#     子查询3
# ) city_deal
# where 成交总额>city_deal.平均成交额
# group by 1

#组合代码
select 城市,成交总额
from
(
   select 城市,sum(成交额) 成交总额,
           (
                select avg(成交总额) 平均成交额
                from
                (
                    select 城市,sum(成交额) 成交总额
                    from test.`8月成交数据`
                    group by 1
                ) deal
            ) 平均成交额
    from test.`8月成交数据`
    group by 1
) city_deal
where 成交总额>city_deal.平均成交额
group by 1
order by 2 desc

#子查询课后练习1:计算战区下城市平均成交额大于5百万的战区的总成交额
#目标字段:sum(成交额) 平均成交额大于5百万的战区的总成交额;
#库表来源:8月成交数据
#连接关系:无
#筛选条件:where/having 城市平均成交额>5百万
#聚合依据:1、城市:先以城市为聚合依据计算出成交额,2、以战区为聚合依据,计算各战区下全部城市的平均成交额,3、全公司:要基于整个公司的数据求出符合要求的战区的成交额总和数值
#梳理思路:1、先以城市为聚合依据计算出每个城市的总成交额;2、以战区为聚合依据来计算对应战区下的全部城市平均成交额;
# 3、求出符合条件的各战区求出战区的成交额总和;4、将符合条件的各战区的成交额求和
#分段编辑:
#1、
select 城市,sum(成交额) 城市成交额
from test.`8月成交数据`
group by 1
;
#2、
select 战区,城市,avg(城市成交额) 平均成交额
from
(
    子查询1
) deal
group by 1,2
;
#3、
select 战区,sum(成交额) 总成交额
from test.`8月成交数据`
where 战区 in
      (
        select 战区
        from (
                子查询2
            ) m_c_a
        where 平均成交额 > 5000000
        group by 1
       )
group by 1
;
#4、
select sum(总成交额) 满足条件战区的总成交额
from
(
    子查询3
)
;
#组合代码:
select sum(总成交额) 满足条件战区的总成交额
from
(
    select 战区,sum(成交额) 总成交额
    from test.`8月成交数据`
    where 战区 in
        (
            select 战区
            from
                (
                    select 战区,城市,avg(城市成交额) 平均成交额
                    from
                    (
                        select 战区,城市,sum(成交额) 城市成交额
                        from test.`8月成交数据`
                        group by 1,2
                    ) deal
                    group by 1,2
                ) m_c_a
            where 平均成交额 > 5000000
            group by 1
        )
    group by 1
)mix

#子查询课后练习2:求出成交额小于城市平均成交额的城市在各自战区的总成交额，按成交额降序排序
#目标字段:各战区的总成交额:sum(成交额) 战区总成交额
#库表来源:8月成交数据
#连接关系:无
#筛选条件:成交额小于城市平均成交额的城市 where/having 成交额<avg(城市成交额) 城市平均成交额
#聚合依据:1、城市:先计算出各城市的总成交额;2、各城市和总成交额:计算出全部城市的平均成交额;
# 3、全公司:基于全公司筛选出成交额小于城市平均成交额的城市和战区;4、战区:按照战区聚合,聚合函数sum(成交额) 战区总成交额
#梳理思路:1、先以城市为聚合依据计算出各城市的总成交额;2、然后根据各城市成交额计算全部城市平均成交额;
# 3、基于全公司筛选出成交额小于城市平均成交额的城市和战区;4、战区:按照战区聚合,求出符合条件的战区的总成交额
#分段编辑:
#1
select 城市,sum(成交额) 城市成交额
from test.`8月成交数据`
group by 1
;

#2
select avg(城市成交额) 城市平均成交额
from
(
    子查询1
) city_deal
;
#3
select 城市
from
(
    子查询1
) c_d
where 城市成交额<
(
    子查询2
)
group by 1
;
#4
select 战区,sum(成交额) 战区总成交额
from test.`8月成交数据`
where 城市 in
(
    子查询3
)
group by 1
;
#组合代码:
select 战区,sum(成交额) 战区总成交额
from test.`8月成交数据`
where 城市 in
(
    select 城市
    from
    (
        select 城市,sum(成交额) 城市成交额
        from test.`8月成交数据`
        group by 1
    ) c_d
    where 城市成交额<
    (
        select avg(城市成交额) 城市平均成交额
        from
        (
            select 城市,sum(成交额) 城市成交额
            from test.`8月成交数据`
            group by 1
        ) city_deal
    )
    group by 1
)
group by 1
order by 战区总成交额 desc

#SQL窗口函数课后练习
#1、求8月各战区成交额最高的三天、这三天的排行、成交额、战区总成交额、以及各自占战区总成交额的占比(保留小数点后3位数)
#------------------------思路1---------------------------(错误:错误点:计算各战区成交额最高的三天维度不是以战区，而是以战区下的城市为维度进行聚合;故成交额计算错误)
#目标字段:各战区成交额最高的三天、三天的排名、成交额;战区总成交额、各自占战区总成交额的占比(保留小数点后3位数)
#库表来源:test.8月成交数据
#连接关系:无
#筛选条件:成交额最高的三天
#聚合依据:各战区:开窗口,以战区为partition by的依据
#梳理思路:1、计算战区成交额最高的三天、排行：先row_number()over(partition by 战区 order by 成交额) 排行;2、战区总成交额sum(成交额)over(partition by 战区) 战区总成交额
#3、
#分段编辑:
#1、
select *
from
(
    select 战区, 成交额, row_number() over (partition by 战区 order by 成交额 desc) 排行
    from test.`8月成交数据`
) rk
where 排行<4
;
#2、
select 战区,m_total.战区总成交额
from
(
    select 战区,sum(成交额)over(partition by 战区) 战区总成交额
    from test.`8月成交数据`
) m_total
group by 1,2

;
#3、
#round(成交额/战区总成交额,3) 占战区总成交额占比
select *,round(成交额/战区总成额,3) 占战区总成交额占比
from
(
    (子查询1) m_rank
) join (子查询2) mdeal_total
on m_rank.战区=mdeal_total.战区
;
#组合代码:
select *,round(成交额/mdeal_total.战区总成交额,3) 占战区总成交额占比
from
(
        select *
        from
        (
            select 战区,日期, 成交额, row_number() over (partition by 战区 order by 成交额 desc) 排行
            from test.`8月成交数据`
        ) rk
        where 排行<4
) m_rank
join
(
        select 战区,m_total.总成交额 战区总成交额
        from
        (
            select 战区,sum(成交额)over(partition by 战区) 总成交额
            from test.`8月成交数据`
        ) m_total
        group by 1,2
) mdeal_total
on m_rank.战区=mdeal_total.战区
;
#-----------------思路二---------------------
#梳理思路
#1、以日期和战区为聚合依据，计算出各战区的每一天的成交额总和，使用cast()函数进行类型转换
select 战区
,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
,sum(成交额) 成交额
from test.`8月成交数据`
group by 1,2

#2、依据这个计算出的每日各战区的成交额总和开窗口函数进行各战区成交额最高前三名的排行以及计算各战区8月的成交额总和以及前三名成交额占各自战区总成交额的占比
#求成交额百分比占比方法:,concat(round(成交额/各战区8月成交额总和*100,3),'%') 成交额占比
select 战区
,日期
,成交额
,row_number() over (partition by 战区 order by 成交额) 排行
,sum(成交额)over(partition by 战区) 各战区8月成交额总和
,concat(round(成交额/各战区8月成交额总和*100,3),'%') 成交额占比
from
(
    子查询1
) m_deal

#3、计算出各战区成交额最高的三天占各战区总成交额的占比并添加筛选条件
select 战区
,mix_deal.日期
,mix_deal.成交额
,mix_deal.排行
,mix_deal.各战区8月成交额总和
,concat(round(成交额/各战区8月成交额总和*100,3),'%') 成交额占比
from
(
    select 战区
    ,日期
    ,成交额
    ,row_number() over (partition by 战区 order by 成交额 desc) 排行
    ,sum(成交额)over(partition by 战区) 各战区8月成交额总和
    from
    (
        select 战区
        ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
        ,sum(成交额) 成交额
        from test.`8月成交数据`
        group by 1,2
    ) m_deal
)   mix_deal
where mix_deal.排行<4


#第二题
#2、求8月各战区日成交额排名前20%的日期、成交额、以及具体排名及排名百分比(以百分比展示，取百分比后一位小数)
#目标字段:select 日期&成交额&具体排名&排名百分比(以百分比展示，取百分比后一位小数)
#库表来源:from 8月成交数据
#连接关系:join?
#筛选条件:where or having?
#聚合依据:group by 1、战区&日期:求出每天各战区的成交额总和 ;partition by 以战区为聚合依据赋予各行数据排名以及该天的总成交额占战区总成交额的占比
#梳理思路:1、先以战区和日期为聚合依据，计算出各战区日成交额总和;2、计算各战区日成交额排名以及成交额的排名百分数;3、where筛选成交额排名前20%的数据出来
#分段编辑:
#1、
select 战区
,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
,sum(成交额) 成交额
from test.`8月成交数据`
group by 1,2
;
#2、
select 战区
,日期
,成交额
,row_number() over (partition by 战区 order by 成交额 desc) 成交额排行
,ROUND(
    cume_dist()
    OVER (
        PARTITION BY m_deal.战区
        ORDER BY m_deal.成交额 desc
    ),3) percentile_rank
from
(
    select 战区
    ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
    ,sum(成交额) 成交额
    from test.`8月成交数据`
    group by 1,2
) m_deal
;
#3、转换为排名百分比,筛选成交额排名前20%的成交额数据
select 战区
,日期
,成交额
,成交额排行
,concat(round(排名百分比*100,1),'%') 排名百分比
from
(
    子查询2
) mix_deal
where percentile_rank<0.2
;
#代码整合:
select 战区
,日期
,成交额
,成交额排行
,concat(round(percentile_rank*100,1),'%') 排名百分比
from
(
    select 战区
    ,日期
    ,成交额
    ,row_number() over (partition by 战区 order by 成交额 desc) 成交额排行
    ,ROUND(
        cume_dist()
        OVER (
            PARTITION BY m_deal.战区
            ORDER BY m_deal.成交额 desc
        ),3) percentile_rank
    from
    (
        select 战区
        ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
        ,sum(成交额) 成交额
        from test.`8月成交数据`
        group by 1,2
    ) m_deal
) mix_deal
where percentile_rank<0.2
;
#第三题
#3、求8月各战区日成交额的极差，按极差降序排序
#目标字段:select 日成交额极差
#库表来源:from 8月成交数据
#连接关系:join
#筛选条件:where/having
#聚合依据:group by
#梳理思路:1、先以战区和日期为聚合依据，计算出各战区日成交额总和;2、然后再求出8月各战区成交额的极差;3、按照极差降序排序
#分段编辑:
#1、
select 战区
,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
,sum(成交额) 成交额
from test.`8月成交数据`
group by 1,2
#2、
select m_deal.战区
,MAX(m_deal.成交额)-MIN(m_deal.成交额) 日成交额极差
from
(
    子查询1
) m_deal
group by 1
order by 日成交额极差 desc
#组合代码:
select m_deal.战区
,MAX(m_deal.成交额)-MIN(m_deal.成交额) 日成交额极差
from
(
    select 战区
    ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
    ,sum(成交额) 成交额
    from test.`8月成交数据`
    group by 1,2
) m_deal
group by 1
order by 日成交额极差 desc

#第四题
#4、求8月东部战区的日成交额，天环比，周同比
#目标字段:成交额、天环比、周同比
#库表来源:8月成交数据
#连接关系:无
#筛选条件:where/having 战区=“东部战区”
#聚合依据:
#梳理思路:
#分段编辑:
#1、求8月东部战区的日成交额
select 战区
,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
,sum(成交额) 成交额
from test.`8月成交数据`
where 战区='东部战区'
group by 1,2

#2、求8月东部战区当前日期前一日的成交额和前7日的成交额
select 战区
,日期
,mili_deal.成交额
,lag(mili_deal.成交额,1) over (partition by mili_deal.战区 order by 日期) 前1日成交额
,lag(mili_deal.成交额,7) over (partition by mili_deal.战区 order by 日期) 前7日成交额
from
(
    #子查询1
    select 战区
    ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
    ,sum(成交额) 成交额
    from test.`8月成交数据`
    where 战区='东部战区'
    group by 1,2
) mili_deal

#3、8月东部战区成交额的天环比和周同比的百分比:天环比--(当前成交额/前一天成交额)-1;周同比--(当前成交额/上周的今天成交额)-1
select 战区
,日期
,成交额
,concat(round((成交额/days_deal.前1日成交额-1)*100,1),'%') 天环比
,concat(round(成交额/days_deal.前7日成交额-1,3)*100,'%') 周同比
from
(
    #子查询2
    select 战区
    ,日期
    ,mili_deal.成交额
    ,lag(mili_deal.成交额,1) over (partition by mili_deal.战区 order by 日期) 前1日成交额
    ,lag(mili_deal.成交额,7) over (partition by mili_deal.战区 order by 日期) 前7日成交额
    from
    (
        #子查询1
        select 战区
        ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
        ,sum(成交额) 成交额
        from test.`8月成交数据`
        where 战区='东部战区'
        group by 1,2
    ) mili_deal
) days_deal
#组合代码:
select 战区
,日期
,成交额
,concat(round((成交额/days_deal.前1日成交额-1)*100,1),'%') 天环比
,concat(round(成交额/days_deal.前7日成交额-1,3)*100,'%') 周同比
from
(
    #子查询2
    select 战区
    ,日期
    ,mili_deal.成交额
    ,lag(mili_deal.成交额,1) over (partition by mili_deal.战区 order by 日期) 前1日成交额
    ,lag(mili_deal.成交额,7) over (partition by mili_deal.战区 order by 日期) 前7日成交额
    from
    (
        #子查询1
        select 战区
        ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
        ,sum(成交额) 成交额
        from test.`8月成交数据`
        where 战区='东部战区'
        group by 1,2
    ) mili_deal
) days_deal

#第五题
#5、求8月东部战区的日成交额、当月总成交额、截至当天的累计成交额、近3天的平均成交额(当日及前2日)、近7天的累计成交额(当日及前后3日)
#1、日成交额
select 战区
,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
,sum(成交额) 成交额
from test.`8月成交数据`
where 战区='东部战区'
group by 1,2

#2、当月成交额
select mili_Deal1.战区,sum(mili_Deal1.成交额) 当月总成交额
from
(
    #子查询1
    select 战区
    ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
    ,sum(成交额) 成交额
    from test.`8月成交数据`
    where 战区='东部战区'
    group by 1
) mili_Deal1
group by 1

#3、截至当天的累计成交额
select 战区
,日期
,sum(成交额)over(partition by 战区 order by 日期 rows between unbounded preceding and current row) 累计到当日的成交额
from
(
    #子查询1
    select 战区
    ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
    ,sum(成交额) 成交额
    from test.`8月成交数据`
    where 战区='东部战区'
    group by 1,2
) mili_Deal1
#4、近3天的平均成交额(当日及前2日)
select mili_Deal1.战区
,avg(mili_Deal1.成交额)over(partition by 战区 order by 日期 rows 2 preceding) 近3天的平均成交额
from
(
    #子查询1
    select 战区
    ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
    ,sum(成交额) 成交额
    from test.`8月成交数据`
    where 战区='东部战区'
    group by 1,2
) mili_Deal1

#5、近7天的累计成交额(当日及前后3日)
select mili_Deal1.战区
,sum(mili_Deal1.成交额)over(partition by 战区 order by 日期 rows between 3 preceding and 3 following) 近3天的平均成交额
from
(
    #子查询1
    select 战区
    ,cast(replace(replace(replace(日期,'年','-'),'月','-'),'日','-')as date) 日期
    ,sum(成交额) 成交额
    from test.`8月成交数据`
    where 战区='东部战区'
    group by 1,2
) mili_Deal1


##############################牛客网SQL《全部题目》解题源代码##################################################3
#SQL211 解法1
#通过子查询查出薪水第二多的数值salary
#然后让salaries的记录中员工的salary=第二多薪水;
#按emp_no升序排序
select emp_no,salary
from salaries
where salary=
(
select distinct salary
from salaries
order by salary desc
limit 1,1
) 
order by emp_no asc

#SQL211 解法2
#第二种解法使用窗口函数,在缓存给salary进行降序排序并给上序列号标签
#给这个窗口表取别名c
#where限定条件对这个窗口表筛选从而查询到符合题目条件的记录
select c.emp_no, c.salary from 
(select emp_no, salary, 
dense_rank() over(order by salary desc) as rk from salaries) as c
where c.rk=2 #限定条件 第二名
limit 1 #如果有多个同值（多个第二名），只取第一个值

#SQL212
#组合代码
4、
select em.emp_no,sa.salary,em.last_name,em.first_name
from employees em join salaries sa
on em.emp_no=sa.emp_no
where sa.salary=
(
    select max(salary)
    from salaries
    where salary !=
    (
        select max(salary) 
        from salaries 
        where to_date='9999-01-01'
    )
) 
and to_date='9999-01-01'


#SQL213
select employees.last_name,employees.first_name,departments.dept_name
from employees left join dept_emp
on employees.emp_no=dept_emp.emp_no
left join departments
on dept_emp.dept_no=departments.dept_no


#SQL214

#SQL215
select emp_no,(h_l.最高工资-h_l.最低工资) growth
from
(
    select emp_no,max(salary)over(partition by emp_no order by to_date rows between unbounded preceding and unbounded following) 最高工资, min(salary)over(partition by emp_no order by to_date rows between unbounded preceding and unbounded following) 最低工资
    from employees join salaries on employees.emp_no=salaries.emp_no
) h_l
where (h_l.最高工资-h_l.最低工资) !=0
order by growth asc

#写法2
select a.emp_no,(b.调整后工资 - a.初始工资) growth
from
  (
    select emp_no,min(salary) 初始工资
    from salaries
    group by 1
  ) a,
  (
    select emp_no,to_date,salary 调整后工资
    from salaries
    group by 1,2,3
    having to_date = "9999-01-01"
  ) b
where a.emp_no = b.emp_no
order by growth

#写法3 通过employees和salaries表连接起来，以连接键hire_date和from_date相连再查出salary即是入职时初始工资
 select e.emp_no, j.salary - s.salary as growth
 from employees e
 join salaries s on e.emp_no = s.emp_no and e.hire_date = s.from_date
 join salaries j on e.emp_no = j.emp_no and j.to_date = '9999-01-01'
 order by growth;

#SQL216
select dep.dept_no
,dep.dept_name
,count(sa.salary) sum
from salaries sa join dept_emp de
on sa.emp_no=de.emp_no join
departments dep on
de.dept_no=dep.dept_no
group by dep.dept_no,dep.dept_name
order by dep.dept_no


#SQL217
select emp_no,salary,dense_rank()over(order by salary desc) t_rank
from salaries
order by salary desc,emp_no asc


#SQL218
select demp.dept_no
,demp.emp_no
,sa.salary
from dept_emp demp join salaries sa on
demp.emp_no=sa.emp_no
where demp.emp_no not in 
(
    select emp_no
    from dept_manager
)


#SQL219
#组合以上分段编辑的代码
select emp_salary.emp_no
,manager_salary.emp_no
,emp_salary.salary
,manager_salary.salary
from
(
    select demp.emp_no
    ,sa.salary
    ,demp.dept_no
    from dept_emp demp join salaries sa on
    demp.emp_no=sa.emp_no
) emp_salary
join
(
    select dman.emp_no
    ,sa.salary
    ,dman.dept_no
    from dept_manager dman join salaries sa on
    dman.emp_no=sa.emp_no
)   manager_salary
on emp_salary.dept_no=manager_salary.dept_no    
where emp_salary.salary > manager_salary.salary 

#SQL220
select demp_ts.dept_no
,demp_ts.dept_name
,demp_ts.title
,count(demp_ts.title)
from
(
    select deps.dept_no
    ,deps.dept_name
    ,tis.title
    from dept_emp demp join departments deps on
    demp.dept_no=deps.dept_no
    join titles tis on
    demp.emp_no=tis.emp_no
) demp_ts
group by 1,2,3
order by dept_no asc,title asc


#SQL221

#SQL222
#SQL223
#组合以上步骤的代码
select fi.film_id
,fi.title
from film fi left join film_category fc on
fi.film_id=fc.film_id
where fc.category_id is null 

#SQL224

select film.title
,film.description
from film
where film.film_id in
(
    select fica.film_id
    from category ca join film_category fica
    on ca.category_id=fica.category_id
    where ca.name='Action'
)

#SQL225

#SQL226

select concat(em.last_name,' ',em.first_name) name
#concat函数可以用于字符串拼接，根据题目要求first_name和last_name之间需要加上空格' '
from employees em


#SQL227
create table if not exists actor(
    actor_id smallint(5) not null primary key comment'主键id'
    ,first_name varchar(45) not null comment'名字'
    ,last_name varchar(45) not null comment'姓氏'
    ,last_update timestamp not null default (datetime('now','localtime')) comment'日期'
)
##在创建基本表的sql语句时注意
#设置主键primary key
#设置默认时间default (datetime('now','localtime'))

#SQL228
insert into actor(actor_id,first_name,last_name,last_update)
values(1,'PENELOPE','GUINESS','2006-02-15 12:34:33'),(2,'NICK','WAHLBERG','2006-02-15 12:34:33')

#SQL229
#忽略
insert ignore into actor
values(3,'ED','CHASE','2006-02-15 12:34:33')

#SQL230
#创建一个actor_name表,并将actor表中所有first_name以及last_name导入actor_name表中
#创建一个actor_name表
drop table if exists actor_name;
create table actor_name(
    first_name varchar(45) not null comment'名字',
    last_name  varchar(45) not null comment'姓氏'
);
#插入/导入到新创建的actor_name表格
insert into
    actor_name
#从actor表中选择字段first_name和last_name导入到actor_name
select
    first_name,
    last_name
from
    actor;

#SQL231
#1. create (unique) index 索引名 on 表名（列名）
create unique index uniq_idx_firstname on actor(first_name);
create index idx_lastname on actor(last_name);

#2. alter table 表名 add (unique) index 索引名（列名）
alter table actor add unique index uniq_idx_firstname(first_name);
alter table actor add index idx_lastname(last_name);

#SQL232
#SQL233
#SQL234
#SQL235
#SQL236
#代码
#1、
with t as (
        select min(id)  min_id
        from titles_test
        group by emp_no
    )
#2、
delete from titles_test
where id not in (
    select min_id
    from t
) 

#SQL237
update titles_test set to_date=null,from_date='2001-01-01'
where to_date='9999-01-01'

#SQL238
#解法1
replace into titles_test
select 5,10005,title,from_date,to_date
from titles_test
where id=5;
#解法2
replace into titles_test values(5,1005,'Senior Engineer','1986-06-26','9999-01-01')

#SQL239
alter table titles_test rename titles_2017

#SQL240
ALTER TABLE audit
ADD CONSTRAINT FOREIGN KEY (emp_no)
REFERENCES employees_test(id);

#SQL241
#SQL242
#1、先从获取到奖金的员工表中查出emp_no
select emp_no
from emp_bonus
#2、更新表格中的salary字段
update salaries 
set salary = salary*1.1 
where salaries.emp_no in
(
    select emp_no
    from emp_bonus
) and to_date='9999-01-01'

#SQL243
#SQL244
#1、先从获取到奖金的员工表中查出emp_no
select emp_no
from emp_bonus
#2、更新表格中的salary字段
update salaries 
set salary = salary*1.1 
where salaries.emp_no in
(
    select emp_no
    from emp_bonus
) and to_date='9999-01-01'

#SQL245
#SQL246
#SQL247
select dept_no,group_concat(emp_no) employees
from dept_emp
group by 1

#SQL248
select avg(salary) avg_salary
from salaries
where salary not in
(
    select max(salary)
    from salaries
    where to_date='9999-01-01'
) and salary not in 
(
    select min(salary)
    from salaries
    where to_date='9999-01-01'
)
and to_date='9999-01-01'

#SQL249
select *
from employees
limit 5,5

#SQL250
#SQL251
#思路1、使用not exists
select *
from employees em
where not exists
(
    select de.emp_no
    from dept_emp de
    where em.emp_no=de.emp_no
)

#思路2、使用not in
select *
from employees em
where em.emp_no not in
(
    select de.emp_no
    from dept_emp de
)

#SQL252
#SQL253
select ems.emp_no
,ems.first_name
,ems.last_name
,emb.btype
,sa.salary
,case when emb.btype=1 then salary*0.1 when emb.btype=2 then salary*0.2 else salary*0.3 
end
from employees ems join emp_bonus emb on
ems.emp_no=emb.emp_no join salaries sa on
emb.emp_no=sa.emp_no
where sa.to_date='9999-01-01'

#SQL254
#思路1
select sa.emp_no
,sa.salary
,sum(sa.salary)over(order by emp_no asc rows between 2 preceding and current row) running_total
from salaries sa
where sa.to_date='9999-01-01'   

#思路2
select sout.emp_no ,sout.salary ,(select sum(sin.salary)  from salaries as sin where sin.emp_no <= sout.emp_no and sin.to_date='9999-01-01' and sout.to_date='9999-01-01') as running_total
from salaries as sout
where sout.to_date='9999-01-01'

#SQL255
select first_name
from employees
where first_name
in
(
    select frk.first_name
    from
    (
        select *
        ,row_number()over(order by first_name) rk
        from employees
    ) frk
    where frk.rk % 2 !=0
)

#SQL256
select g_count.number
from
(
    select number,count(number) cnt
    from grade
    group by 1
)  g_count
where g_count.cnt >= 3
order by number asc

#SQL257
select psr.id
,psr.number
,psr.t_rank
from
(
    select id
    ,passing_number.number
    ,dense_rank()over(order by number desc) t_rank
    from passing_number
    group by 1,2
) psr   
order by psr.number desc,id asc

#SQL258
#使用左连接，因为根据题目要求，即使是为分配任务的人也要输出，且输出结果按照person的id升序排序
select p.id
,p.name
,t.content
from person p left join task t on
p.id=t.person_id
order by p.id asc

#SQL259
select date
,round(fail_count/total_count,3) p
from 
(
    select date
    ,sum(case when type = 'no_completed' then 1 else 0 end) fail_count
    ,count(date) total_count
    from email
    where email.send_id not in 
    (
        select user.id
        from user
        where is_blacklist=1
    ) and email.receive_id not in 
    (
        select user.id
        from user
        where is_blacklist=1
    ) 
    group by 1
) e_detail

#SQL260
#思路1
select user_id
,max(date)  d 
from login    
group by user_id
order by user_id

#思路2
#用窗口函数FIRST_VALUE
select distinct user_id
,FIRST_VALUE(date) over(partition by user_id order by date desc) d 
from login 

#SQL261
#1、先查出牛客用户最近的登录日期和对应的user_id
select user_id
,max(date) date
from login
group by 1

#2、步骤1的别名是result,分别以各自相同的连接键连接四张表;其中login和result通过date和user_id两个连接键来连接;client和login则以client_id连接;user和login则以user_id连接
select u.name u_n,c.name c_n,l.date
from login l 
join
(
    select user_id
    ,max(date) date
    from login
    group by 1
) result 
on (l.date=result.date and l.user_id=result.user_id) 
join client c on l.client_id=c.id 
join user u on l.user_id=u.id
order by u.name asc

#SQL262
#2、首先计算新登录用户的总数量；思路：可以用去重后的登录用户计数count即可
select count(distinct user_id)
from login

#3、然后计算成功留存（新登录用户次日成功登录）的用户的数量；思路：新登录的用户次日还登录了，翻译过来-->即表示（user_id,current_date+1）还在login表格中，（其中user_id表示新登录用户id，current_date表示登录时间）
from login l2
where (l2.user_id,l2.date) in 
(
    select l3.user_id,date_add(min(l3.date),interval 1 day)
    from login l3
    group by 1
)

#根据留存率的公式计算
select round(count(distinct l2.user_id)*1.0/(select count(distinct l1.user_id)
from login l1),3)

#组合代码
select round(count(distinct l2.user_id)*1.0/(select count(distinct l1.user_id)
from login l1),3)
from login l2
where (l2.user_id,l2.date) in 
(
    select l3.user_id,date_add(min(l3.date),interval 1 day)
    from login l3
    group by 1
)

#SQL263
select l2.date
,ifnull(new,0)
from login l2 left join
(
    select l1.date
    ,count(user_id) new
    from login l1
    where (user_id,l1.date) in
    (
        select user_id
        ,min(date)
        from login
        group by 1
        order by 1
    )
    group by 1
    order by 1
) r_t on l2.date=r_t.date
group by 1
order by 1

#SQL264
select rt5.date2,round(rt4.sl_u/case when rt5.user_new=0 then 1 else rt5.user_new end,3) p
from
(
    select date_sub(rt3.date,interval 1 day) date1,  rt3.user_sl sl_u
    from
    (
        select l6.date,ifnull(rt2.sl_user,0) user_sl
        from    
        (
            select l4.date,count(l4.user_id) sl_user
            from login l4
            where (l4.user_id,l4.date) in
            (
                select l5.user_id,date_add(min(l5.date),interval 1 day)
                from login l5
                group by 1
                order by 1
            )
            group by 1
            order by 1
        ) rt2 right join
        login l6 on l6.date=rt2.date
        group by 1
        order by 1
    ) rt3
) rt4 join 
(
    select l3.date date2,ifnull(rt.new_user,0) user_new
    from login l3 left join 
    (
        select l2.date,count(l2.user_id) new_user
        from login l2
        where (l2.user_id,l2.date) in
        (
            select l1.user_id,min(l1.date)
            from login l1
            group by 1
            order by 1
        )
        group by 1
        order by 1
    ) rt on l3.date=rt.date
    group by 1
    order by 1
) rt5 on rt4.date1=rt5.date2

######以上代码日期前后相差一日，故不符合题目要求######
######以下代码会从牛客每个人最近的登录日期(三)和牛客每个人最近的登录日期(四)俩题结合起来解决，这三题是环环相扣、由内到外、知1推3的存在;
#牛客每个人最近的登录日期(三)--每个日期新用户次日还登录的人的个数
select login.date,ifnull(n1.new_num,0) as second_login_num
from login 
left join 
(
    select l1.date
    ,count(distinct l1.user_id) as new_num
    from login l1
    join login l2 on l1.user_id=l2.user_id and l2.date=date((l1.date),'+1 day') 
    where l1.date =
    (
        select min(date) from login where user_id=l1.user_id
    )
    group by l1.date
) n1
on login.date = n1.date
group by login.date

#牛客每个人最近的登录日期(四)--每个日期的新登录用户总数
select login.date,ifnull(n1.new_num,0)
from login 
left join 
(
    select l1.date
    ,count(distinct l1.user_id) as new_num
    from login l1
    where l1.date =
    (
        select min(date) 
        from login 
        where user_id=l1.user_id
    )
    group by l1.date
) n1
on login.date = n1.date
group by login.date

#牛客每个人最近的登录日期(五)--求每个日期新用户的留存率
select second_login.date, round(ifnull(second_login.second_login_num *1.0/ first_login.first_num,0),3)
from 
(
    select login.date,ifnull(n1.new_num,0) as second_login_num
    from login 
    left join 
    (
        select l1.date,count(distinct l1.user_id) as new_num
        from login l1 
        join login l2 on l1.user_id=l2.user_id and l2.date=date_add((l1.date),interval 1 day)
        where l1.date =
        (
            select min(date) 
            from login 
            where user_id=l1.user_id
        )
        #这一步where子查询是在连接完俩张表格之后进行筛选的,让表中l1.date都转换成首次登录的日期;
        #这样日期后面跟着的次日新用户登录数量就不是次日而是当日
        group by l1.date
    ) n1
    on login.date = n1.date
    group by login.date
) second_login

join 

(
    select login.date,ifnull(n1.new_num,0) as first_num
    from login 
    left join 
    (
        select l1.date,count(distinct l1.user_id) as new_num
        from login l1
        where l1.date =
        (
            select min(date) 
            from login 
            where user_id=l1.user_id
        )
        group by l1.date
    ) n1
    on login.date = n1.date
    group by login.date
) first_login
on second_login.date=first_login.date


#SQL265
select user.name
,login_passing.date
,sum(login_passing.number)over(partition by user.name rows between unbounded preceding and current row)
from user join
(
    select pn.user_id
    ,pn.date
    ,pn.number
    from passing_number pn join login l1  on 
    l1.date=pn.date and l1.user_id=pn.user_id
) login_passing on user.id=login_passing.user_id
order by 2,1

#SQL266
select job
,round(avg(score),3)
from grade
group by 1#以job:岗位位聚合依据
order by 2 desc#以分数为排序依据，按照分数降序排序

#SQL267
select g2.id
,g2.job
,g2.score
from grade g2
join
(
    select g1.job,avg(g1.score) avg_score
    from grade g1
    group by g1.job
) avg on g2.job=avg.job
where g2.score>avg.avg_score
order by g2.id

#SQL268
select rt.id
,rt.name
,rt.score
from 
(
    select g.id id
    ,l.name name
    ,g.score score
    ,dense_rank()over(partition by l.name order by score desc) rk
    from grade g join language l on
    g.language_id=l.id
) rt
where rt.rk<=2
order by rt.name,rt.score desc,rt.id

#SQL269
select  job
,floor((cou nt(*)+1)/2) 'start'
,ceil((count(*)+1)/2) 'end'
from grade
group by job
order by job

#SQL270
select rt.id
,rt.job
,rt.score
,rt.rk
from
(
    select id
    ,job
    ,score
    ,dense_rank()over(partition by job order by score desc) rk
    from grade
    order by id
) rt join
(
    select  job
    ,floor((count(*)+1)/2) 'start'
    ,ceil((count(*)+1)/2) 'end'
    from grade
    group by job
    order by job
) rt1 on rt.job=rt1.job
where rt.rk=rt1.start or rt.rk=rt1.end
order by rt.id

#SQL271
select id
,user_id
,product_name
,status
,client_id
,order_info.date
from order_info
where (order_info.date>'2025-10-15') and (product_name='C++' or product_name='Java' or product_name='Python') and status='completed'
order by 1

#SQL272
#1、首先，以user_id为partition by聚合依据开窗聚合，count(*)计算每个用户的分组下记录的数量是否>=2(外查询的筛选条件)，内查询把筛选条件date&status&product_name三个题目要求的条件添加到where后然后根据user_id、product_name俩个字段进行group by；
select user_id
,product_name
,count(*)over(partition by user_id) ct
from order_info
where date>'2025-10-15' and status='completed' 
and (product_name='C++' or product_name='Java' or product_name='Python')
group by 1,2

#2、将查询出用户下单量count(**)的查询作为内查询，别名为count_sale，添加上筛选条件where ct>=2;
select count_sale.user_id
from
(
    select user_id
    ,product_name
    ,count(*)over(partition by user_id) ct
    from order_info
    where date>'2025-10-15' and status='completed' 
    and (product_name='C++' or product_name='Java' or product_name='Python')
    group by 1,2
)   count_sale
where count_sale.ct>=2
group by 1
order by 1

#SQL273
select order_info.id
,order_info.user_id
,order_info.product_name
,order_info.status
,order_info.client_id
,order_info.date
from 
(
    select user_id
    ,product_name
    ,count(*)over(partition by user_id) ct
    from order_info
    where date>'2025-10-15' and status='completed' 
    and (product_name='C++' or product_name='Java' or product_name='Python')
    group by 1,2
)   count_sale join order_info  on count_sale.user_id=order_info.user_id and count_sale.product_name=order_info.product_name
where count_sale.ct>=2 and status='completed' 
order by order_info.id

#SQL274
select sale1.user_id
,sale1.date first_buy_date
,sale1.ct
from
(
    select user_id
    ,product_name
    ,date
    ,count(*)over(partition by user_id) ct
    ,row_number()over(partition by user_id order by date asc) rk
    from order_info
    where date>'2025-10-15' and status='completed' 
    and (product_name='C++' or product_name='Java' or product_name='Python')
    group by 1,2,3
) sale1
where sale1.rk=1 and sale1.ct>=2
order by user_id

#SQL275
select sales1.id
,sales1.first_buy_date
,sales2.second_buy_date
,sales1.cnt
from
(
    select sale1.user_id id
    ,sale1.date first_buy_date
    ,sale1.ct cnt
    from
    (
        select user_id
        ,product_name
        ,date
        ,count(*)over(partition by user_id) ct
        ,row_number()over(partition by user_id order by date asc) rk
        from order_info
        where date>'2025-10-15' and status='completed' 
        and (product_name='C++' or product_name='Java' or product_name='Python')
        group by 1,2,3
    ) sale1
    where sale1.rk=1 and sale1.ct>=2
    order by id
) sales1 

join

(
    select sale2.user_id id
    ,sale2.date second_buy_date
    ,sale2.ct cnt
    from
    (
        select user_id
        ,product_name
        ,date
        ,count(*)over(partition by user_id) ct
        ,row_number()over(partition by user_id order by date asc) rk
        from order_info
        where date>'2025-10-15' and status='completed' 
        and (product_name='C++' or product_name='Java' or product_name='Python')
        group by 1,2,3
    ) sale2
    where sale2.rk =2 and sale2.ct>=2
    order by id
) sales2 on sales1.id=sales2.id and sales1.cnt=sales2.cnt

#SQL276
select rt2.id
,rt2.is_group_buy
,c.name
from
(
    select id
    ,is_group_buy
    ,client_id
    from
    (
        select user_id
        ,client_id
        ,id
        ,is_group_buy
        ,count(*)over(partition by user_id) ct
        from order_info
        where date>'2025-10-15' and status='completed' 
        and (product_name='C++' or product_name='Java' or product_name='Python')
    ) rt1
    where rt1.ct>=2
    order by id
) rt2 left join client c on rt2.client_id=c.id
order by id

#SQL277
select ifnull(c.name,'GroupBuy') source
,count(*) cnt
from
(
    select id
    ,is_group_buy
    ,client_id
    from
    (
        select user_id
        ,client_id
        ,id
        ,is_group_buy
        ,count(*)over(partition by user_id) ct
        from order_info
        where date>'2025-10-15' and status='completed' 
        and (product_name='C++' or product_name='Java' or product_name='Python')
    ) rt1
    where rt1.ct>=2
    order by id
) rt2 left join client c on rt2.client_id=c.id
group by 1
order by source


#SQL278
select job
,sum(num) cnt
from resume_info
where year(date)=2025
group by 1
order by cnt desc

#SQL279
select job
,date_format(date,'%Y-%m') mon
,sum(num) cnt
from resume_info
where year(date)=2025
group by 1,2
order by mon desc,cnt desc

#SQL280
select rt1.job
,first_year_mon
,first_year_cnt
,second_year_mon
,second_year_cnt
from
(
    select job
    ,date_format(date,'%Y-%m') first_year_mon
    ,month(date) month1
    ,sum(num) first_year_cnt
    from resume_info
    where year(date)=2025
    group by 1,2,3
    order by first_year_mon desc,job desc
) rt1

join

(
    select job
    ,date_format(date,'%Y-%m') second_year_mon
    ,month(date) month2
    ,sum(num) second_year_cnt
    from resume_info
    where year(date)=2026
    group by 1,2,3
    order by second_year_mon desc,job desc
) rt2 on rt1.job=rt2.job and rt1.month1=rt2.month2

#SQL281
select grade
,sum(class_grade.number)over(order by grade rows between unbounded preceding and current row) t_rank
from class_grade

#SQL282
select grade 
from
(
    select *
    ,lag(number1,1,0) over() as number2 
    from 
    (
        select *, sum(number) over(order by grade) number1 
        ,(select round(sum(number)/2,0) from class_grade) s1
        ,(select round((sum(number)+1)/2,0) from class_grade) s2
        from class_grade
    ) s
) s3
where (number2 < s1 and number1 >= s1) or (number2 < s2 and number1 >= s2)

#SQL283
select user.name
,rt3.sum_grade
from
(
    select rt2.user_id user_id
    ,rt2.sum_grade sum_grade
    from
    (
        select rt1.user_id user_id
        ,rt1.sum_grade sum_grade
        ,row_number()over(order by sum_grade desc) rk
        from
        (
            select user_id
            ,sum(grade_num)over(partition by user_id order by grade_num desc) sum_grade
            from grade_info
        ) rt1
    ) rt2
    where rt2.rk=1
) rt3 join user on rt3.user_id=user.id

#SQL284
select user.id
,user.name
,rt3.sum_grade
from
(
    select rt2.user_id user_id
    ,rt2.sum_grade sum_grade
    from
    (
        select rt1.user_id user_id
        ,rt1.sum_grade sum_grade
        ,dense_rank()over(order by sum_grade desc) rk
        from
        (
            select user_id
            ,sum(grade_num)over(partition by user_id order by grade_num desc) sum_grade
            from grade_info
        ) rt1
    ) rt2
    where rt2.rk=1
) rt3 join user on rt3.user_id=user.id

#SQL285
select user.id
,user.name
,rt2.last_grade
from
(
    select rt1.user_id
    ,rt1.last_grade last_grade
    ,dense_rank()over(order by last_grade desc) rk
    from
    (
        select g1.user_id user_id
        ,(g1.add_grade - ifnull(g2.reduce_grade,0)) last_grade
        from
        (
            select user_id
            ,sum(grade_num)over(partition by user_id order by grade_num desc) add_grade
            from grade_info
            where grade_info.type='add'
        ) g1 left join
        (
            select user_id
            ,sum(grade_num)over(partition by user_id order by grade_num desc) reduce_grade
            from grade_info
            where grade_info.type='reduce'
        ) g2 on g1.user_id=g2.user_id
    ) rt1
) rt2 join user on user.id=rt2.user_id
where rt2.rk=1
group by 1,2,3

#SQL286(中等，网易校招笔试题)
select g.id
,g.name
,g.weight
,sum(count) total
from goods g join trans t on
g.id=t.goods_id
group by 1
having total>20 and weight<50
order by g.id asc


#SQL156
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


#SQL157
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

#SQL158
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

#SQL159
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

#SQL160
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

#SQL161
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

#SQL162
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

#SQL163
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

#SQL164
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

#SQL165
SELECT user_grade, round(count(uid)/(select count(distinct uid) from tb_user_log),2) ratio
FROM 
(
    SELECT uid
    ,(CASE WHEN DATEDIFF(DATE((SELECT MAX(in_time) FROM tb_user_log)),date(max(in_time)))<=6
            AND DATEDIFF(DATE((SELECT MAX(in_time) FROM tb_user_log)),date(min(in_time)))>6
            THEN '忠实用户'
            WHEN DATEDIFF(DATE((SELECT MAX(in_time) FROM tb_user_log)),date(min(in_time)))<=6
            THEN '新晋用户'
            WHEN DATEDIFF(DATE((SELECT MAX(in_time) FROM tb_user_log)),date(max(in_time))) BETWEEN 7 AND 29
            THEN '沉睡用户'
            WHEN DATEDIFF(DATE((SELECT MAX(in_time) FROM tb_user_log)),date(max(in_time)))>29
            THEN '流失用户' END
    ) AS user_grade
    FROM tb_user_log
    GROUP BY uid    
) a
GROUP BY user_grade
ORDER BY ratio DESC;

#SQL166
select rt2.in_time dt
,rt2.user_cnt dau
,round(rt1.new_user/rt2.user_cnt,2)
from 
(
    select in_time,sum(new) as new_user
    from 
    (
        select uid
        ,date(in_time) as in_time
        ,if(row_number() over (partition by uid order by in_time) = 1, 1, 0) new
        from tb_user_log
    ) b
    group by in_time
) rt1 join
(
    select in_time
    ,count(distinct uid) as user_cnt
    from
    (
        select uid,date(in_time) as in_time
        from tb_user_log
        union 
        select uid,date(out_time) as in_time
        from tb_user_log
    ) a
    group by in_time
) rt2 on rt1.in_time=rt2.in_time
order by dt
