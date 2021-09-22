In this section, I'm going to describe a common problem in today's era of big data and show how you would solve it in Python. 
Naturally, there's a naive solution, which will work, but would demonstrate significant inefficiencies. And with a small change in data structure, 
you will, once again, have an efficient code to solve your problem. This is known as process and time series data that you might find in the stock market, 
in currency values, or sensor data coming in from a numerous set of sensors. And in this era of big data is unlimited amount of information that we're 
retrieving on a very timely basis. Sometimes there's just a great volume of data. And it's much too large to store in memory, and we have to find some 
way to partition that up into manageable chunks. Sometimes we've got high-speed arrival of data. And we can't possibly keep it all in memory. 
And we only want to process information that is relatively recent, in any event. So we find some way to deal with that. Turns out, there's a 
single solution that would get us toward the problem. Here's a small example of the euro-USD currency exchange. And the graph shows you what 
is called a candlestick graph. And in there, every one of those candlesticks represents a particular price of the currency, when it opened, what its high 
point was, what its low point was, and what its value is when it actually closed. This is a daily graph. So it goes over from May until July over a 
span of several months. But this information can be increasingly fine-grained to be down to the level of not even just minutes, even sub-minute data. 
And if you imagine, in a year, you'd have 31 million ticks of data that you might have to process. This is just one currency. You may have dozens of currencies 
that you're following. And one of the common things that happens when dealing with these large data series is you're trying to look for trends. And based 
on those trends, you can make decisions, whether buy or sell. Well, I've got two trend lines that are shown here. These are what's called the moving average, 
where I want to look at the currency values, but the fluctuations are too great. So instead what I do is, I choose a period of time. And I choose the average 
of the currency during that period of time-- say, 14 days. And so over a 14-day period, using the red line you see here, you can see that the currency value 
goes down, then goes back up again, then comes down again. And if I'm trying to understand a trend, it's not entirely clear that there is, in fact, a trend there.
 However, if you extend the period to be 30 days long, then I get this white line, which shows a slow but generally upward trend since May. Now, those are both 
two examples of what's called a moving average. From the same data series, I want to be able to create different moving averages. Now, how would I do this? 
Well, let's imagine that we actually had all this information coming in. And I'm not going to worry yet right now about how I get the information.
 I'll just assume that I have the information available for me to do in Python. And so to compute a moving average, what you need to do is compute a 
window, during which you have a set of currency values. And then over all the information that's in that window, you compute as average. Here's a small 
example. Now, imagine that you've got a series of data events coming to you over time. A and B have already happened, and they're in the past. 
I've got these six events-- C, D, E, F, G, and H. They're all within my window. And there's a new event on the horizon that has not yet been processed, 
I. So from those six events in my window, I can compute the moving average of the price. When the next tick arrives, then I want I to be now part of the window.
 And data element C, which had been the first element the window, is now gone or is no longer part of my calculation. So now I want the moving average of the values 
D, E, F, G, H, and I. This, once again, requires a computation. If you look at this particular representation, you probably can already see that there might 
be some inefficiencies in how I go about computing this moving average. It comes down to this. If I'm going to use a list to store all my values in a window, 
then when a new value comes on in, I have to do two things. I have to append the new value to the end of the list. But then I have to make sure to remove the zeroth 
element from the list, because that's the oldest one and is no longer needed. So a Python function, I might just write here-- very simple. If I've got a window,
 I want to add this value to that window. And so the window has a certain size. And until I've reached my size, I just keep appending the values. But once 
I have reached my size, I have to make sure to delete the oldest value in the list, which is, of course, window bracket 0, and then append that new value at the end.
 So this is a very concise and simple implementation. However, that very simplicity is going to be our downfall, because it actually means that there's an 
inefficient operation here, just lurking. And you have to pay attention to these whenever you're trying to write efficient code. The len operation, as we know, 
is a constant time operation. So that's not a problem. Appending to a list is also not a problem. That's a constant time operation. But what about deleting? 
If you're deleting the first element from the window, this is an order and operation. As you apply this function over and over again, repeatedly-- 
let's say within 31 million ticks-- you start to realize the cost will accrue to be so much that you just won't be able to respond in a timely fashion. 
Clearly, what I need is the ability to update this window and to do so not in linear time, but in a constant time. And that's the basic challenge. 
And so when you're working with Python lists, as a programmer, use their simplicity. But always remember that underlying it all is a array-- a continuous 
block in memory. And so if you start deleting or reordering the elements of that array, it's going to cost you. And so deleting a window is an order and 
operation. And we have to find some way to eliminate that cost. The list itself, I can't do anything about. That structure is provided for me. And I can use
 it in all my Python programs. What I need to do is create a new data type and somehow find a way to use the list as this representation but, once again, provide
 different methods so I can control the access to the representation. So there's this concept called a circular buffer. It was quite popular when computers were 
first introduced, because we were working with such constrained memory. We had to find some way to maximize every single byte. It may have fallen out of favor. 
But in this case, the circular buffer is exactly the thing I want to use. Just imagine, let me use a list as a fixed sized buffer. If I want to have a window of 30 
elements, I'll start with the list that's ready to accept 30 elements. And I'm going to maintain the illusion that this list wraps around from end to the beginning.
 So here, for example, if I've got a set of six elements in my list-- C, D, E, F, G, and H-- in my mind, I want to imagine, well, C is the first element in the list. 
And it goes C all the way up to H. But then the next element after H is, in fact, element C. So this is just a way of looking at my representation and 
imposing my own view of it. Now, if I do it this way, I can now look at my circular buffer as a queue, which means I can add to the end, I can remove from the front,
 and whenever I want those operations-- add to the end, remove from the front-- I want those both to be amortized constant operations. I can't with the list, because
 if you delete the zeroth element of a list, it might take order N. But to make this work with a circular buffer, there's a very nice thing that we can do. 
If I think about my list as a fixed size storage, when I append the next element in the list, I'm just going to make sure that I override the oldest element once the
 buffer is full. So there's that initial phase where I'm adding elements to the buffer, and it's not yet full. But once I get to a full buffer,
 whenever I add a new element, it should override the oldest element that's there. So if I maintain these two indices called Low and High, I can use them to track 
where I am in the circular buffer. And I never have to allocate any more memory or delete any element from the list. Instead, I just overwrite and interpret it in the 
right fashion. So here, if my buffer had these six elements-- C, D, E, F, G, and H, which represents this circular buffer here-- C, D, E, F, G, and H-- and then
 I add K to the buffer, my buffer over here, all I do is update this location, because C was the oldest element. All I do is, I put K there.
 And I don't have to change or touch any of the other values. And so my buffer-- my circular buffer-- now becomes D, E, F, G, H, K. So I'm no longer looking at 
this list in fixed coordinates-- that 0 is the first element and n minus 1 is the last element. I now have these two other indices called Low and High. 
Low tells me where the circular buffer starts. In this case, it starts at position 1. And High tells me, where does it end? In this case, it ends at position 0. 
So I have to do a little bit of modulo arithmetic to make this work. But in general, you should see that I can get some really impressive cost savings, because 
I'm not going to ever have to delete the zeroth element of a list. Instead, I'm just going to overwrite its value and achieve the [INAUDIBLE] that I want.
 So we start by defining types, by coming up with this class definition. And in this case, I need to keep track of the buffer. That's my list. 
That's going to store all my values. And in fact, it's going to be a fixed size buffer. Once I know how big the circular buffer, is I just allocate a buffer of 
that size
. Then I maintain two of the values-- my low and my high. Those will keep track of the indices that I was talking about. I want to keep track, for convenience, the 
size of the buffer. So I don't always have to just compute the length of that buffer. And that's what the size location gives you. And as one other enhancement, 
I'm going to keep track of a count, which tells me how many elements are in the circular buffer. Now, naturally, given the low and the high, I can compute how many 
elements are in the circular buffer. But if I choose to store that information, which is just an additional constant time operation, I make my job easier when 
it comes time to answer the fundamental question, is my circular buffer empty, or how many elements are in my buffer? So as you can see here, this is now my 
representation. And using the design principle I just introduced, I'm separating function from the behavior. The representation is just a list. And on that, 
I'm imposing my own understanding-- that low is just an index, and high is an index. And whenever you add an element to the circular buffer, you find where the current 
value of high is, and that's where you put it. And whenever you remove an element, you go to wherever the low is, and that's where you remove it from.
 So I'm maintaining all that information. There's one more nice thing here that I'm going to just keep track of. When the list is not empty, then low is the index of the 
first element. And when the list is not empty, then high is the index of the next location to use. Once it becomes full, then all the values are there. 
And all I do is maintain where the low and the high is, so I know where to start and where to end. I'm going to show you how to implement a circular buffer from scratch.
 In some of the data structure we use in this course, it's a little more complicated. So I won't have the time to do that always from scratch.
 But this is the good example, because it shows you the way that you should approach designing your own data structures and some of the mechanical things you have to 
do to make it work. As we've seen in the description of this course, I need to be able to define new types. And in Python, that's done using the Class keyword,
 as you see here. I'm defining a new class called Circular Buffer. It has a basic constructor that will be used to create that circular buffer when we start. 
As I just mentioned, my circular buffer is going to keep track of a number of information. And this is a fixed size buffer. So when you first are given information,
 I know I'm going to have the size. So we'll start. I refer to my object as Self, because that's the parameter and this is the basic Python idiom. And I store 
information with the object. So I know the size. That's great. This is a fixed buffer. So I'm going to create a fixed buffer that will store everything that I want.
 And I start with this simple Python idiom, which says, create a list of a certain size. Well, there it is. It'll be all empty. They'll all be none. And it'll be
 that size. I know I want to keep track of both the low and the high. So I'll do that. So here's my circular buffer. And I need to think about the operation that 
I want to provide. So we had already described these already. I need to know, is my circular buffer empty? And then I need to know, have I added an element to my 
circular buffer? That's this one. I'm going to need to have a remove, which removed the oldest one. Now, to make all this work, I'll take them one at a time.
 Assuming that I keep track of my count, which I do want to do, this is a very easy one to do. Self-count equal 0-- so that's done. And what you see, as I set things up,
 is you define the type, you define the key operations, and then you implement them one at a time. Once I'm done with that, I will go through and add the right 
documentation to describe both the functionality of each operation, as well as the performance of each. What happens when I want to add a value to this? Well,
 I will find it interesting to not only have an isEmpty, but to have an isFull. And now I can more accurately describe what happens when you add. 
So if I'm full, then I know I want to do something. Otherwise, if I'm not full, then I can just keep adding on, which is actually quite easy to do. 
So if I'm going to add while I'm not full, then my count is going to go up by 1. That much is clear. If I'm full and I add an element, I'm going to remove another 
element. And the number of elements that I keep remains the same. Let's talk about this case in a little more detail. Once I'm full, I have to remember that the low,
 which is my index value that keeps track of where I'm starting from, has got to advance to the next element, because I've gotten rid of the oldest one. 
And what's nice about this is that Python-- in fact, every programming language-- has a really nice modulo operator to let you keep track of modular arithmetic. 
So if I constantly increment my low, eventually I hit the end of the array. Then I can make sure to go back to position 0 when I'm done. Almost there. 
This is taking care of the fact that I've bumped forward my low. But what would I have done about where the new value gets located? And what's nice is that the 
location of the new value is always wherever the high is pointing to. So that's why I put it. And then I just make sure I advance the high point location, 
because next time, it'll be ready to go. So I've just implemented the add for the circular buffer. If I want to understand how this is working, well,
 I kind of have to run it. And the nature of Python is such that these are the kind of experiments you might find yourself doing quite commonly. 
I'm going to create a new circular buffer size 5. If you look for this information, it's, of course, not giving you anything that's useful. 
And for this reason, whenever you write data structures in Python, you should always come along and put in a representation function that gives you at least some 
information that you can use and look at. And so I'll just provide a very simple one here. So if my circular buffer is empty, then I just want to return an empty 
circular buffer. Otherwise, I'm going to do a nice Python thing here. I just want to provide a list-- a comma-separated list-- of all my values. And there's a nice, 
simple Python way to do that. And again, you may have never seen this before. But it's a nice idiom to be aware of. You may know at least how Python can split and 
join lists. And it's a very common thing to do with strings, as well. What I want to do is join together commas between each of the elements that I have. 
And this is a nice sort of Python way of doing that, which basically says, go through all the values that you have, and just map them down to what you want them to be.
 And this is almost there. I'll show you what it looks like in a moment. When I do this like this, I have an empty circular buffer. When I add my first value,
 I won't, but I'll show that now. To add the value, I'm going to call this Method. Once again, to reiterate, if it's full, then I have to bump up my low, because now 
I'm shifting my location in the circular buffer. If I'm not full, we'll just increase your count. And I always make sure to insert the new value wherever the 
current high location is. So if I add 10 to that-- I don't have this ability yet. I need to provide the iteration. This is a fundamental thing about Python, once again,
 is that Python aims for simplicity. For every collection you have, whether it's a list or a tuple or a dictionary, they all seem to offer this ability to iterate over 
all the values. It's really no secret how to do that. And so we'll do that now. I'm going to provide the iterated capability for this circular buffer. 
What I need to do is find some way to represent all the values that are in the circular buffer. Now, I know that the values are contained between index low up to,
 but not including, high. So let's just make that work. I start at low. And I know that I have this many items that are in my circular buffer. And so what I'll just 
do is even simpler. This is another reason why I keep track of the count. It makes this code easier to write. But as long as I've got more elements here, let me
 yield up this value. Yield is a Python wonder. This is what makes so much Python code easier to write and efficient to execute. What I've just defined is an iterator 
that's a generator. Instead of returning a value as a long list, what I'm going to do is return it to you by different means, one at a time, which is suitable 
for an iteration. I'm just going to yield that particular value. Once that has been returned, or yielded, as it is, I advance my index to the next one, which we know
 how to do that, which says, well, whatever your index is, just go to the next one. Modulo the size of these lists, because I always have to make sure that, 
in a circular buffer, I wrap around to get back to the beginning. And to make sure that this loop actually terminates, I just make sure that I decrement my count by 1. 
So now I have a really nice iterator that's provided here. You'll see this structure repeated many times throughout this course, because once you understand
 how to write an iterator or how to write a representation function, the idioms are clear what you need to do. We're now ready to execute this code. 
I, once again, have a circular buffer. I'm going to add the value 5. And now it knows that it's got one. Excellent. Let me add the value 7. Now that's there, as well. 
You can see what I'm going to do-- add this a couple more times. Eventually, I'm going to get up to my size of 5. Now, the big trick-- what happens when I add the 
next element? Well, as you can see, C is indeed full. And so when it calls add, it's going to do a little bit of arithmetic to make sure that my low and high are
 properly synchronized. So if I add 15, my circular buffer now has 7, 9, 11, 13, 15. That's what it represents. But I'm going to show you the little secret.
 What is C, after all? C is this circular buffer. I'm going to reach on in and look at my actual buffer-- remember, the list that I'm using to store everything. 
The actual buffer is this 15, 7, 9, 11, 13. And that's after all, because the low is going to be index position 1, which starts off at 7, then 9, 11, 13.
 And the high, in this case, is index position 1. That's the next location where the next element would be added. So it's actually an interesting thing. 
Whenever C low and C high are the same, you also know that you're full if you have a count. So I actually have everything here. And now I need to make sure 
I implement remove, as well. So to do the remove, I'll just do a quick little check. And I'll say, well, if you're empty, then you can't do anything. 
And it's very useful to be able to define, as part of the API, the exceptions that would happen if someone calls that operation under the wrong circumstances. 
Well, what I want to do-- to remove, I have to make sure I get the lowest index value to return. Well, that's easy enough. So I have that value here.
 Now I need to make sure I advance low, because, after all, that's got to be pointed to the next one. So I have that there, as well. And once I'm done with that, for
 convenience, I'm keeping track of the count. So I make sure to remember that I've just removed one. And then I return the value. We've just completed the circular
 buffer implementation. Let me show you. So with this implementation here, I'll do an implementation with just three elements now. So I've got these three elements in
 my circular buffer. When I add the next one, as you'll see, I get 3, 5, and 7, because the 1 is no longer there. When I say remove, I get 3, because that's 
the oldest one. And now my circular buffer is just 5 and 7. If I add-- there's room for one more. So he'll go at the end. And then finally, it'll push the 5 out.
 And now I have it. So this very simple data structure takes advantage of the list to store all the information. And by controlling access to those lists, 
I've guaranteed that these four methods-- isEmpty, isFull, Add, Remove Self-- are all now constant, amortized operations. I've now shown you the implementation 
of the circular buffer. Let's summarize what we actually have. There are certain read-only operations, like isEmpty, isFull. I will also want to have a len operation,
 which I'll add and you'll see in the code. There are operations to add and remove. And I can now state accurately that those are all order 1 operations, because 
I only append-- or in the case, remove, all you're really doing is adjusting indices inside of the list. So you're not removing or moving other elements. 
And the iterator operation that I did-- it's convenient to look at the iterator and just recognize that pretty much every iterator will be order n, because you have 
no choice but to go through all the elements that you have. With all that information, I've now provided a circular buffer. It has the operation that I want with 
the performance that I want. And this data type now can be used in numerous ways, as we'll now describe.

