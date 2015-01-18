---
layout: post
title: "TCP&IP���"
description: "TCP&IP���"
categories: [notes]
tags: [TCP&IP]
alias: [/2015/01/18/]
---
# TCP&IP���

��ǩ���ո�ָ����� TCP/IP

---
## TCP Flags

## TCP Options
`EOF` End of Option List.��ʶTCPѡ���б������

`NOP` No Operation(used for padding).�����ֽ���䣬��ΪTCPͷ���������ֽڵ���������

`MMS` Maxumum Segment Size.TCP���Ķ����Ĵ�С��ֻ��TCP���ݲ��ֵĴ�С��������TCPͷ����IPͷ����IPv4ͨ����1460��IPv6ͨ����1440����20��Ϊһ��MTUΪ1500����IPv6ͷ����IPv4��20bytes

`WSOPT` Windows Scaling Factor(left-shift amount window).��Ҫ��Ϊ����չ�������ڵĴ�С����ΪTCPͷ����window sizeֻ��16λ,ͨ������������������ƣ���ʹ���ڴ�С�ﵽ���1G

`SACK-Permitted` Sender supports SACK options.��ʶ���ͷ�֧��SACK��

`SACK` SACK block(out-of-order data recevied).��Ҫ��Ϊ��ϻ������ڣ���Ϊ���ڵĴ��ڽ��շ����յ������ݿ���������ģ�Ϊ��������ܣ�ACKʱ����ͨ��SACKѡ��˵���Ѿ����յ���Щ����seq number����ΪTCP Options��С�����ƣ����ֻ��˵��3�������������飬��SACK Block�����������շ����Ը��õ�ѡ���ط���Щseq number��segment��

`TSOPT` Timestaps option.ʱ��������ʱ���ֻ����Եĸ�����ͷ��ͽ��ܷ�����Ҫͬ��������ά���Ϳ����ˣ��������������ѡ������������ɣ����ͷ����Լ���ʱ������ڵ�һ���֣����շ����յ���ʱ�򣬰ѷ��͵�ʱ���ԭ�ⲻ����Ų���ڶ������֣����ڵ�һ���ַ����Լ���ʱ������������ν�����ȥ��ʱ��������ã�һ��Ϊ�˹���TTL����Ҫ��;��ӵ�������㷨�ϣ���һ�����������Ƕ�֪��seq number����ֻ��32λ�������ڴ���ܴ����ݣ�6G�������ںܴ�1G���Լ������ٶȺܿ������¿��ܻ���֣�֮ǰ�Ķ�ʧ��segment��ͨ���ط������Ѿ����͹�ȥ�ˣ��������ĳ��segment��seq numberһ������ʱ����շ����ݱȽϷ��ͷ���ʱ�����֪��������ϡ�������Ч�ˣ����Protection Against Wrapped Sequence Numbers��

`UTO` User Timeout(abort after idle time). ����˵���ǵȴ�ACK�ĳ�ʱʱ�䣬������ͷ��������ʱ�仹û�ȵ�ACK�ͻ��ش������ʱ������Ҫ���ش��ĳ�ʱʱ��(RTO)Ҫ������Ϊ�������ʱ�����Ϊ����ʧ�ܻ�ر����ӣ�������UTOs����̫����̫�����ܵ�����Դ���ױ��ľ���Ҳ����̫�̣�̫�̿��ܵ������ӱ���ǰ�رա�������Ҫע��������ѡ��ֻ�Ǹ����Ӹ��˵�һ������ֵ������ʹ�õ�USER_TIMEOUT���ܱ�֤һ�������ѡ�����õ�ֵ��ʵ�ֵ�ʱ��һ������ϵͳ��������õȽ���ѡ�񣬴�����µĹ�ʽ��
`USER_TIMEOUT = min(U_LIMIT,max(ADV_UTO,REMOTE_UTO,L_LIMIT))`
`ADV_UTO`��һ�˸��Զ����õ�ֵ��`REMOTE_UTO`�ǶԶ˵����õ�ֵ��`U_LIMIT`�Ǳ���ϵͳ���õ����ֵ��L_LIMIT����Сֵ��

`TCP-AO` Authentication options(using various algorithms).�������֮ǰ��TCP-MD5�������TCP�İ�ȫ�ԡ����ѡ��Ƚ��»�û�й㷺ʹ�á���˵����ÿ�δ���֮ǰ��������Ҫ��ͨ��ĳ�ַ�ʽ����һЩ�����key��Ȼ��ÿ�ζ��ò�ͬ�Ĺ���key(in-band signaling)����һ������Ĺ�ϣ�㷨(RFC5926)����segment��hashֵ�����������segment�ڴ��������û�б��޸ġ��ؼ�����δ����͹�����Щkey��

2��`Experimental` Reserved for experimental use.������Ϊʵ����;��

-----

`MTU`




