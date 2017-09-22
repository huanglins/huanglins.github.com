---
layout:     post
title:      "MySQL 相关语法及函数"
subtitle:   "x_x"
date:       2017-08-26
author:     "vincent"
header-img: "img/post-bg-13-mysql.jpg"
catalog: true
tags:
    - MySQL
---

## 函数

#### 合计函数

函数 | 说明
------- | -------
AVG(column) | 返回某一列的平均值
COUNT(column) | 返回某一列的行数（不包括 NULL 值）
COUNT(*) | 返回被选中的行数
MAX(column) | 返回某列的最高值
MIN(column) | 返回某列的最低值
SUM(column) | 返回某列的总和
GROUP_CONCAT(column) | 返回某列值连接组合而成的结果（通过 `,` 连接）

#### 数学函数

函数 | 说明
------- | -------
ABS(x) | 返回 x 的绝对值。
CEIL(x) / CEILING(x) | 返回大于或等于 x 的最小整数。 `SELECT CEIL(1.5)` 返回 2
FLOOL(x) | 返回小于或等于 x 的最大整数。 `SELECT FLOOR(1.5)` 返回1
RAND() | 返回 0-1 之间的随机数。
SIGN(x) | 返回 x 的符号。负数返回-1，0返回0，正数返回1。
PI() | 返回圆周率 (3.141593)
TRUNCATE(x, y) | 返回保留数值 x 到小数点后 y 位的值
ROUND(x) | 返回离 x 最近的整数。`SELECT ROUND(1.23456)` 返回 1
ROUND(x, y) | 保留离 x 最近的整数，但截断的时候要进行四舍五入。`SELECT ROUND(1.23456,3)` 返回 1.235
POWER(x, y) | 返回 x 的 y 次方。`SELECT POWER(2,3)` 返回 8
SQRT(x) | 返回 x 的平方根。`SELECT SQRT(25)` 返回 5
EXP(x) | 返回 e(自然对数的底 2.718281828459)的 x 次方。
MOD(x, y) | 返回 x 除以 y 以后的余数。`SELECT MOD(5, 3)` 返回2

#### 字符串函数

函数 | 说明
------- | -------
ASCII(s) | 返回字符串 s 的 ASCII 码值。
CHAR_LENGTH(s) | 返回字符串 s 的字符数。`SELECT CHAR_LENGTH('你好123')` 返回 5
LENGTH(s) | 返回字符串 s 的长度。`SELECT LENGTH('你好123')` 返回 9
CONCAT(s1, s2, ...) | 将字符串 s1, s2 等多个字符串合并为一个字符串
CONCAT_WS(x, s1, s2, ...) | 同 CONCAT(s1, s2,...) 函数，不过两个字符串连接之间要加上 x。
UPPER(s) | 将字符串 s 的所有字母变成大写字母
LOWER(s) | 将字符串 s 的所有字母变成小写字母
LEFT(s, n) | 返回字符串 s 的前 n 个字符
RIGHT(s, n) | 返回字符串 s 的后 n 个字符
REPEAT(s, n) | 将字符串重复 n 次
SPACE(n) | 返回 n 个空格
REPLACE(s, s1, s2) | 将字符串 s2 替代字符串 s 中的字符串 s1
STRCMP(s1, s2) | 比较 s1和s2.返回 -1，0，1
SUBSTRING(s1, s2) | 获取从字符串 s 中的第 n 个位置开始长度为 len 的字符串。
REVERSE(s) | 将字符串 s 反转
LOAD_FILE(file_name) | 读入文件并作为一个字符串返回文件内容

#### 日期和时间函数

函数 | 说明
------- | -------
NOW() | 返回当前的日期和时间
CURDATE() | 返回当前的日期
CURTIME() | 返回当前的时间
MONTH(d) | 返回日期 d 中的月份值
MONTHNAME(d) | 返回日期 d 中的月份名称。如：August
HOUR(d) | 返回时间 d 的小时值
MINUTE(d) | 返回时间 d 的分钟值
SECOND(d) | 返回时间 d 的秒钟值 
DAYNAME(d) | 返回日期d 中是星期几。如：Monday,Tuesday
DAYOFWEEK(d) | 返回日期d 是星期几。如：1星期日，2星期一..
WEEK(d) | 返回时间d 是本年的第几个星期，范围:0->53
DAYOFMONTH(d) | 计算时间d 是本月的第几天
DAYOFYEAR(d) | 计算时间d 是本年的第几天
QUARTER(d) | 计算时间d 是本年的第几个季节。返回 1-4
UNIX_TIMESTAMP() | 以 unix 时间戳的形式返回当前时间
FROM_UNIXTIME(10位时间戳) | 将 unix 时间戳转换为 YYYY-MM-dd HH:mm:ss 格式的时间
DATEDIFF(d1, d2) | 计算日期 d1-d2 之间相隔的天数
ADDDATE(d, n) | 计算日期 d 加上 n 天的日期
ADDDATE(d, INTERVAL expr type) | 计算日期 d 加上一个日期值后的日期。例如: `ADDDATE(n, INTERVAL 1 DAY)` 表示加上一天，`ADDDATE(INTERVAL -1 MONTH)` 表示减去一个月。
SUBDATE(d, n) | 计算日期 d 减去 n 天的日期
DATEDIFF(d1, d2) | 计算日期 d1 与 d2 之间相隔的天数

#### 条件判断

函数 | 说明
------- | -------
IF(expr, v1, v2) | 例如：`SELECT IF(1 > 0, '正确', '错误')`
IFNULL(v1 , v2) | 如果 v1 的值不为 NULL，则返回 v1，否则返回 v2。
CASE | 

**CASE 语法**

> 第一种 

```
CASE
	WHEN e1
	THEN v1
	WHEN e2
	THEN v2
	...
	ELSE vn
END
```

CASE 表示函数开始，END 表示函数结束。如果 e1，则返回 v1；如果 e2 成立，则返回 v2；当前全部不成立则返回 vn。而当一个成立，后面的就不执行。

> 第二种

```
CASE expr
	WHEN e1 THEN v1
	WHEN e2 THEN v2
	...
	ELSE vn
END
```
如果表达式 expr 的值等于 e1，则返回 v1；如果等于 e2，则返回 v2。否则返回 vn。

#### 系统信息函数

函数 | 说明
------- | -------
VERSION() | 返回数据库的版本号
CONNECTION_ID() | 返回服务器的连接数
USER() | 返回当前的用户
LAST_INSERT_ID() | 返回最近生成的 AUTO_INCREMENT 值

#### 加密函数

函数 | 说明
------- | -------
PASSWORD(str) | 对 str 字符串进行加密
MD5(str) | 对字符串 str 进行散列，用于一些普通的不需要解密的数据进行加密
SHA(str) | SHA 加密
SHA1(str) | SHA1 加密
ENCODE(str, key) , DECODE(str, key) | 使用 key 作为秘钥加密解密字符串 str，这两个函数是一对的。加密和解密。*非要注意的是，对应字段用 blob 类型*

#### 其他函数

函数 | 说明
------- | -------
CONVERT(s USING utf8) | 将字符串转换成 utf8


## 参考学习地址
[MySql函数大全](http://www.jianshu.com/p/32bc449a1bf6) <br/>
[SQL 教程](http://www.w3school.com.cn/sql/index.asp) <br/>
[MySql常用函数汇总](http://www.jb51.net/article/40179.htm)


