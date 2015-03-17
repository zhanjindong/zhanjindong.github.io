---
layout: post
title: "Google Protocol Buffer 简单介绍"
description: "Google Protocol Buffer 简单介绍"
categories: [notes]
tags: [protobuf]
alias: [/2015/03/15/]
utilities: fancybox,unveil,highlight
---

以下内容整理自[官方文档][3]。

* Kramdown table of contents
{:toc .toc}

## 为什么使用 Protocol Buffers
{: #why-use-protobuf}

通常序列化和解析结构化数据的几种方式？

- 使用Java默认的序列化机制。这种方式缺点很明显：性能差、跨语言性差。
- 将数据编码成自己定义的字符串格式。简单高效，但是仅适合比较简单的数据格式。
- 使用XML序列化。比较普遍的做法，优点很明显，人类可读，扩展性强，自描述。但是相对来说XML结构比较冗余，解析起来比较复杂性能不高。

`Protocol Buffers`是一个更灵活、高效、自动化的解决方案。它通过一个.proto文件描述你想要的数据结构，它能够自动生成解析
这个数据结构的Java类，这个类提供高效的读写二进制格式数据的API。最重要的是`Protocol Buffers`的扩展性和兼容性很强，只要遵很少的规则
就可以保证向前和向后兼容。

## .proto文件
{: #proto-file}

{% highlight Java %}
package tutorial;

option java_package = "com.example.tutorial";
option java_outer_classname = "AddressBookProtos";

message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    required string number = 1;
    optional PhoneType type = 2 [default = HOME];
  }

  repeated PhoneNumber phone = 4;
}

message AddressBook {
  repeated Person person = 1;
} 	
{% endhighlight %}

### Protocol Buffers 语法
{: #protobuf-language}

.proto文件的语法跟Java的很相似，message相当于class，enum即枚举类型，
基本的数据类型有`bool`, `int32`, `float`, `double`, 和 `string`，类型前的修饰符有：

- required 必需的字段
- optional 可选的字段
- repeated 重复的字段

> NOTE 1: 由于历史原因，数值型的repeated字段后面最好加上[packed=true]，这样能达到更好的编码效果。
> repeated int32 samples = 4 [packed=true];

> NOTE 2: Protocol Buffers不支持map，如果需要的话只能用两个repeated代替：keys和values。

字段后面的1,2,3…是它的字段编号（tag number），注意这个编号在后期协议扩展的时候不能改动。`[default = HOME]`即默认值。
为了避免命名冲突，每个.proto文件最好都定义一个`package`，package用法和Java的基本类似，也支持`import`。

{% highlight Java %}
import "myproject/other_protos.proto";
{% endhighlight %}

**扩展**

PB语法虽然跟Java类似，但是它并没有继承机制，它有所谓的`Extensions`，这很不同于我们原来基于面向对象的`JavaBeans`式的协议设计。

`Extensions`就是我们定义`message`的时候保留一些`field number` 让第三方去扩展。

{% highlight Java %}
message Foo {
  required int32 a = 1;
  extensions 100 to 199;
}
{% endhighlight %}


{% highlight Java %}
message Bar {

    optional string name =1;
    optional Foo foo = 2;
} 

extend Foo {
	optional int32 bar = 102;
}
{% endhighlight %}

也可以嵌套：

{% highlight Java %}
message Bar {

    extend Foo {
	optional int32 bar = 102;
    }

    optional string name =1;
    optional Foo foo = 2;
} 
{% endhighlight %}

Java中设置扩展的字段：

{% highlight Java %}
BarProto.Bar.Builder bar = BarProto.Bar.newBuilder();
bar.setName("zjd");
		
FooProto.Foo.Builder foo = FooProto.Foo.newBuilder();
foo.setA(1);
foo.setExtension(BarProto.Bar.bar,12);
		
bar.setFoo(foo.build());
System.out.println(bar.getFoo().getExtension(BarProto.Bar.bar));
{% endhighlight %}

个人觉得使用起来非常不方便。

有关PB的语法的详细说明，建议看[官方文档][6]。PB的语法相对比较简单，一旦能嵌套就能定义出非常复杂的数据结构，基本可以满足我们所有的需求。


## 编译.proto文件
{: #compiler-proto-file}

可以用Google提供的一个proto程序来编译，Windows版本下载[protoc.exe][1]。基本使用如下：

	protoc.exe -I=$SRC_DIR --java_out=$DST_DIR $SRC_DIR/addressbook.proto


.proto文件中的`java_package`和`java_outer_classname`定义了生成的Java类的包名和类名。


## Protocol Buffers API
{: #protobuf-api}

`AddressBookProtos.java`中对应.proto文件中的每个message都会生成一个内部类：`AddressBook`和`Person`。
每个类都有自己的一个内部类`Builder`用来创建实例。messages只有`getter`只读方法，builders既有`getter`方法也有`setter`方法。

**Person**

{% highlight Java %}
// required string name = 1;
public boolean hasName();
public String getName();

// required int32 id = 2;
public boolean hasId();
public int getId();

// optional string email = 3;
public boolean hasEmail();
public String getEmail();

// repeated .tutorial.Person.PhoneNumber phone = 4;
public List<PhoneNumber> getPhoneList();
public int getPhoneCount();
public PhoneNumber getPhone(int index);	
{% endhighlight %}


**Person.Builder**

{% highlight Java %}
// required string name = 1;
public boolean hasName();
public java.lang.String getName();
public Builder setName(String value);
public Builder clearName();

// required int32 id = 2;
public boolean hasId();
public int getId();
public Builder setId(int value);
public Builder clearId();

// optional string email = 3;
public boolean hasEmail();
public String getEmail();
public Builder setEmail(String value);
public Builder clearEmail();

// repeated .tutorial.Person.PhoneNumber phone = 4;
public List<PhoneNumber> getPhoneList();
public int getPhoneCount();
public PhoneNumber getPhone(int index);
public Builder setPhone(int index, PhoneNumber value);
public Builder addPhone(PhoneNumber value);
public Builder addAllPhone(Iterable<PhoneNumber> value);
public Builder clearPhone();
{% endhighlight %}

除了JavaBeans风格的getter-setter方法之外，还会生成一些其他getter-setter方法：

- has_ 非repeated的字段都有一个这样的方法来判断字段值是否设置了还是取的默认值。
- clear_  每个字段都有1个clear方法用来清理字段的值为空。
- _Count  返回repeated字段的个数。
- addAll_  给repeated字段赋值集合。
- repeated字段还有根据index设置和读取的方法。

## 枚举和嵌套类
{: #nested-and-enum}

message嵌套message会生成嵌套类，enum会生成未Java 5的枚举类型。

{% highlight Java %}
public static enum PhoneType {
  MOBILE(0, 0),
  HOME(1, 1),
  WORK(2, 2),
  ;
  ...
}
{% endhighlight %}


## Builders vs. Messages
{: #builders-vs-messages}

所有的messages生成的类像Java的string一样都是不可变的。要实例化一个message必须先创建一个builder，
修改message类只能通过builder类的setter方法修改。每个setter方法会返回builder自身，这样就能在一行代码内完成所有字段的设置：

{% highlight Java %}
Person john =
  Person.newBuilder()
    .setId(1234)
    .setName("John Doe")
    .setEmail("jdoe@example.com")
    .addPhone(
      Person.PhoneNumber.newBuilder()
        .setNumber("555-4321")
        .setType(Person.PhoneType.HOME))
    .build();
{% endhighlight %}

每个message和builder提供了以下几个方法：

- isInitialized(): 检查是否所有的required字段都已经设置；
- toString(): 返回一个人类可读的字符串，这在debug的时候很有用；
- mergeFrom(Message other): 只有builder有该方法，合并另外一个message对象，非repeated字段会覆盖，repeated字段则合并两个集合。
- clear(): 只有builder有该方法，清除所有字段回到空值状态。

## 解析和序列化
{: #parsing-and-serialization}

每个message都有以下几个方法用来读写二进制格式的protocol buffer。关于二进制格式，看[这里][2]（可能需要翻墙）。

- byte[] toByteArray();  将message序列化为byte[]。
- static Person parseFrom(byte[] data); 从byte[]解析出message。
- void writeTo(OutputStream output); 序列化message并写到OutputStream。
- static Person parseFrom(InputStream input); 从InputStream读取并解析出message。


每个`Protocol buffer`类提供了对于二进制数据的一些基本操作，在面向对象上面做的并不是很好，如果需要更丰富操作或者无法修改.proto文件
的情况下，建议在生成的类的基础上封装一层。


### Writing A Message
{: #writing-a-message}

{% highlight Java %}
import com.example.tutorial.AddressBookProtos.AddressBook;
import com.example.tutorial.AddressBookProtos.Person;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.PrintStream;

class AddPerson {
  // This function fills in a Person message based on user input.
  static Person PromptForAddress(BufferedReader stdin,
                                 PrintStream stdout) throws IOException {
    Person.Builder person = Person.newBuilder();

    stdout.print("Enter person ID: ");
    person.setId(Integer.valueOf(stdin.readLine()));

    stdout.print("Enter name: ");
    person.setName(stdin.readLine());

    stdout.print("Enter email address (blank for none): ");
    String email = stdin.readLine();
    if (email.length() > 0) {
      person.setEmail(email);
    }

    while (true) {
      stdout.print("Enter a phone number (or leave blank to finish): ");
      String number = stdin.readLine();
      if (number.length() == 0) {
        break;
      }

      Person.PhoneNumber.Builder phoneNumber =
        Person.PhoneNumber.newBuilder().setNumber(number);

      stdout.print("Is this a mobile, home, or work phone? ");
      String type = stdin.readLine();
      if (type.equals("mobile")) {
        phoneNumber.setType(Person.PhoneType.MOBILE);
      } else if (type.equals("home")) {
        phoneNumber.setType(Person.PhoneType.HOME);
      } else if (type.equals("work")) {
        phoneNumber.setType(Person.PhoneType.WORK);
      } else {
        stdout.println("Unknown phone type.  Using default.");
      }

      person.addPhone(phoneNumber);
    }

    return person.build();
  }

  // Main function:  Reads the entire address book from a file,
  //   adds one person based on user input, then writes it back out to the same
  //   file.
  public static void main(String[] args) throws Exception {
    if (args.length != 1) {
      System.err.println("Usage:  AddPerson ADDRESS_BOOK_FILE");
      System.exit(-1);
    }

    AddressBook.Builder addressBook = AddressBook.newBuilder();

    // Read the existing address book.
    try {
      addressBook.mergeFrom(new FileInputStream(args[0]));
    } catch (FileNotFoundException e) {
      System.out.println(args[0] + ": File not found.  Creating a new file.");
    }

    // Add an address.
    addressBook.addPerson(
      PromptForAddress(new BufferedReader(new InputStreamReader(System.in)),
                       System.out));

    // Write the new address book back to disk.
    FileOutputStream output = new FileOutputStream(args[0]);
    addressBook.build().writeTo(output);
    output.close();
  }
}
{% endhighlight %}

### Reading A Message
{: #reading-a-message}

{% highlight Java %}
import com.example.tutorial.AddressBookProtos.AddressBook;
import com.example.tutorial.AddressBookProtos.Person;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintStream;

class ListPeople {
  // Iterates though all people in the AddressBook and prints info about them.
  static void Print(AddressBook addressBook) {
    for (Person person: addressBook.getPersonList()) {
      System.out.println("Person ID: " + person.getId());
      System.out.println("  Name: " + person.getName());
      if (person.hasEmail()) {
        System.out.println("  E-mail address: " + person.getEmail());
      }

      for (Person.PhoneNumber phoneNumber : person.getPhoneList()) {
        switch (phoneNumber.getType()) {
          case MOBILE:
            System.out.print("  Mobile phone #: ");
            break;
          case HOME:
            System.out.print("  Home phone #: ");
            break;
          case WORK:
            System.out.print("  Work phone #: ");
            break;
        }
        System.out.println(phoneNumber.getNumber());
      }
    }
  }

  // Main function:  Reads the entire address book from a file and prints all
  //   the information inside.
  public static void main(String[] args) throws Exception {
    if (args.length != 1) {
      System.err.println("Usage:  ListPeople ADDRESS_BOOK_FILE");
      System.exit(-1);
    }

    // Read the existing address book.
    AddressBook addressBook =
      AddressBook.parseFrom(new FileInputStream(args[0]));

    Print(addressBook);
  }
}
{% endhighlight %}

## 扩展协议
{: #extending}

实际使用过程中，`.proto`文件可能经常需要进行扩展，协议扩展就需要考虑兼容性的问题，
`Protocol Buffers`有良好的扩展性，只要遵守一些规则：

- 不能修改现有字段的`tag number`；
- 不能添加和删除`required`字段；
- 可以删除`optional`和`repeated`字段；
- 可以添加`optional`和`repeated`字段，但是必须使用新的`tag number`。

向前兼容（老代码处理新消息）：老的代码会忽视新的字段，删除的option字段会取默认值，repeated字段会是空集合。

向后兼容（新代码处理老消息）：对新的代码来说可以透明的处理老的消息，但是需要谨记新增的字段在老消息中是没有的，
所以需要显示的通过has_方法判断是否设置，或者在新的.proto中给新增的字段设置合理的默认值，
对于可选字段来说如果.proto中没有设置默认值那么会使用类型的默认值，字符串为空字符串，数值型为0，布尔型为false。

注意对于新增的repeated字段来说因为没有`has_`方法，所以如果为空的话是无法判断到底是新代码设置的还是老代码生成的原因。

	建议字段都设置为optional，这样扩展性是最强的。


## 编码
{: #encoding}

英文好的可以直接看[官方文档][5]，但我觉得博客园上[这篇文章][4]说的更清楚点。


总的来说`Protocol Buffers`的编码的优点是非常紧凑、高效，占用空间很小，解析很快，非常适合移动端。
缺点是不含有类型信息，不能自描述（[使用一些技巧][7]也可以实现），解析必须依赖`.proto`文件。

Google把PB的这种编码格式叫做`wire-format`。

<a class="post-image" href="/assets/images/posts/message-buffer.jpg">
<img itemprop="image" data-src="/assets/images/posts/message-buffer.jpg" src="/assets/js/unveil/loader.gif" alt="message-buffer.jpg" />
</a>


PB的紧凑得益于**Varint**这种可变长度的整型编码设计。

<a class="post-image" href="/assets/images/posts/message-buffer-varint.jpg">
<img itemprop="image" data-src="/assets/images/posts/message-buffer-varint.jpg" src="/assets/js/unveil/loader.gif" alt="message-buffer-varint.jpg" />
</a>


（图片转自[http://www.cnblogs.com/shitouer/archive/2013/04/12/google-protocol-buffers-encoding.html][5]）


## 对比XML 和 JSON
{: #vs-xml-and-json}


### 数据大小
{: #data-size}

我们来简单对比下`Protocol Buffer`和`XML`、`JSON`。

**.proto**

{% highlight Java %}
message Request {
  repeated string str = 1;
  repeated int32 a = 2;
}
{% endhighlight %}


**JavaBean**

{% highlight Java %}
public class Request {
	public List<String> strList;
	public List<Integer> iList;
}
{% endhighlight %}

首先我们来对比生成数据大小。测试代码很简单，如下：

{% highlight Java %}
public static void main(String[] args) throws Exception {
    int n = 5;
    String str = "testtesttesttesttesttesttesttest";
    int val = 100;
    for (int i = 1; i <=n; i++) {
        for (int j = 0; j < i; j++) {
            str += str;
        }
        protobuf(i, (int) Math.pow(val, i), str);
        serialize(i, (int) Math.pow(val, i), str);
        System.out.println();
    }
}

public static void protobuf(int n, int in, String str) {
    RequestProto.Request.Builder req = RequestProto.Request.newBuilder();

    List<Integer> alist = new ArrayList<Integer>();
    for (int i = 0; i < n; i++) {
        alist.add(in);
    }
    req.addAllA(alist);

    List<String> strList = new ArrayList<String>();
    for (int i = 0; i < n; i++) {
        strList.add(str);
    }
    req.addAllStr(strList);

    // System.out.println(req.build());
    byte[] data = req.build().toByteArray();
    System.out.println("protobuf size:" + data.length);
}

public static void serialize(int n, int in, String str) throws Exception {
    Request req = new Request();

    List<String> strList = new ArrayList<String>();
    for (int i = 0; i < n; i++) {
        strList.add(str);
    }
    req.strList = strList;

    List<Integer> iList = new ArrayList<Integer>();

    for (int i = 0; i < n; i++) {
        iList.add(in);
    }
    req.iList = iList;

    String xml = SerializationInstance.sharedInstance().simpleToXml(req);
    // System.out.println(xml);
    System.out.println("xml size:" + xml.getBytes().length);

    String json = SerializationInstance.sharedInstance().fastToJson(req);
    // System.out.println(json);
    System.out.println("json size:" + json.getBytes().length);
} 
{% endhighlight %}


随着n的增大，`int`类型数值越大，`string`类型的值也越大。我们先将`str`置为空：

<a class="post-image" href="/assets/images/posts/protobuf-int-size.png">
<img itemprop="image" data-src="/assets/images/posts/protobuf-int-size.png" src="/assets/js/unveil/loader.gif" alt="protobuf-int-size.png" />
</a>

还原str值，将`val`置为1：

<a class="post-image" href="/assets/images/posts/protobuf-string-size.png">
<img itemprop="image" data-src="/assets/images/posts/protobuf-string-size.png" src="/assets/js/unveil/loader.gif" alt="protobuf-string-size.png" />
</a>

可以看到对于int型的字段`protobuf`比`xml`和`json`的都要小不少，尤其是xml，这得益于它的`Varint`编码。对于string类型的话，随着字符串内容越多，
三者之间基本就没有差距了。


### 序列化性能
{: #serialization-perf}



### 解析性能
{: #parsing-perf}


[1]: http://jindong.io/assets/downloads/protoc.exe
[2]: https://developers.google.com/protocol-buffers/docs/encoding
[3]: https://developers.google.com/protocol-buffers/docs/javatutorial
[4]: http://www.cnblogs.com/shitouer/archive/2013/04/12/google-protocol-buffers-encoding.html
[5]: http://www.cnblogs.com/shitouer/archive/2013/04/12/google-protocol-buffers-encoding.html
[6]: https://developers.google.com/protocol-buffers/docs/proto
[7]: https://developers.google.com/protocol-buffers/docs/techniques#self-description
