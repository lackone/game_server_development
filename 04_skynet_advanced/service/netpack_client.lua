local socket = require "client.socket"

local fd = socket.connect("127.0.0.1", 8888)

socket.usleep(1 * 1000000)

--“＞”代表这串数据采用大端编码，与netpack模块使用的编码方式相同；
--“H”代表放置一个16位无符号整数，与第二个参数13对应
--c13”代表放置一个13字节长度的字符串，与第三个参数“login,101,134”
--local bytes = string.pack(">Hc13", 13, "login,123,123")
--socket.send(fd, bytes)

--发送错误消息
--local bytes = string.pack(">Hc10", 10, "login,101,")
--socket.send(fd, bytes)
--socket.usleep(1 * 1000000)
--netpack会把第二条消息“134”的前两个字符“13”当作长度信息，并等待非常长的消息内容
--local bytes = string.pack(">c3", "123")
--socket.send(fd, bytes)


--发送不完整消息
local bytes = string.pack(">Hc13Hc4Hc2", 13, "login,123,123", 4, "work", 4, "te")
socket.send(fd, bytes)
socket.usleep(1 * 1000000)
local bytes = string.pack(">c2", "st")
socket.send(fd, bytes)

--关闭
socket.usleep(1 * 1000000)
socket.close(fd)