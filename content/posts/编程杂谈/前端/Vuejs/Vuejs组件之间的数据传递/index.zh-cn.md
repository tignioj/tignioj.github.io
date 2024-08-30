---
date: 2024-08-30T17:24:32+08:00
lastmod: 2024-08-30T18:38:20+08:00
categories:
  - 编程杂谈
  - 前端
  - Vuejs
title: Vuejs组件之间的数据传递
draft: "false"
tags:
  - Vuejs
series: 
description: 本文将涉及watch, ref, emit, provide, inject
---
## 理解watch
### 场景1：引用子组件暴露的数据（错误用法以及纠正）


watch指南： https://cn.vuejs.org/guide/essentials/watchers.html

> 一个返回响应式对象的 getter 函数，只有在返回不同的对象时，才会触发回调

```js
watch(
  () => state.someObject,
  () => {
    // 仅当 state.someObject 被替换时触发
  }
)
```



举例：一个页面组件分配如下

- Page.vue
```js
 // 命名变量和ref相同时会自动绑定，例如这里绑定了ToDoList组件
const todoListRef = ref();  

<FileManager />
<TodoList ref="todoListRef" />
```

其中ToDoList里面暴露了`todoList`数组

- TodoList.vue
```js
const todoList = ref([])  // 这里初始化为一个响应式数组
defineExpose({  
  todoList
})
```

此时希望`FileManager.vue`能拿到这个数组，就需要`Page.vue`先拿到`todoList`，再把它传递给`FileManager.vue`

##### 方法1：当TodoListRef被初始化时引用（watch能用，有更简单的办法）

原理：注意到我们在`Page.vue`中初始化`todolistRef`为响应式值`ref`，但是没传参数，vuejs会在某个生命周期将其与子模板中`ref`属性的模板赋值，这个过程经历了todoListRef.value 从未定义到定义的变化。
```js
const todoListRef = ref();  // 未定义(没传参数就是没定义，ref(null)表示定义一个空)
<TodoList ref="todoListRef" />  // ref属性和todoListRef变量相同，会在某个生命周期给这个响应式变量赋值
```

此时我们可以通过watch监听到这个赋值的过程
- Page.vue
```js

const todoListRef = ref();
const todoList = ref([]);// 初始化为空数组

watch(() => todoListRef.value, (newVal, oldVal) => {  
    // console.log('父组件检测到子组件 todoList 修改', newVal);  
  console.log('父组件检测到todoListRef被赋值', newVal);  
  todoList.value = newVal.todoList  // 成功拿到子模版暴露的值
})
```


此时你会注意到，在`onMounted()`里面监听`todoListRef`是无效的，因为在`onMounted`之后，`todoListRef`对象不会再变化，除非你手动改变他

```js
onMounted(()=> {  
  watch(() => todoListRef.value, (nv, ov) => {  
    // 检测失败， 除非子组件的todoList修改成了另一个对象  
    todoList.value = nv;  
  })
```

手动改变
```js
onMounted(()=> {  
  watch(() => todoListRef.value, (nv, ov) => {  
    // 这里会检测到后面修改的null，但是无意义
    todoList.value = nv;  
    console.log('检测到todoListRef.value被修改', nv);  
  })  
  // 手动改变todoListRef的值
  todoListRef.value = null
```

##### 方法2，在onMount直接赋值
但是由于Vue渲染顺序是先子模版再父模板，因此如果我们可以直接再`onMount`里面获取子模版暴露的值而无需watch...

```js
const todoListRef = ref();
const todoList = ref([]);//也可以为ref(null)，反正在调用.value=xxx的时候就是另一个对象了
onMounted(()=> {
	//此时todoListRef早就被初始化完成
	// todoList.value原本是[]，此时重新赋值，就会丢弃原来的[]
	todoList.value = todoListRef.value.todoList
})

...
<TodoList ref="todoListRef" />
```

### 场景2：监听子组件todoList数组的变化

- TodoList.vue 通过网络请求，更新了数组内容，如何在另一个组件FileManager拿到这个值？
```js
const todoList = ref([])
// 异步更新todoList数组内容
fetch(url).then(res.json()).then(data=> {
	if(data.success) {
		data.arr.forEach(item=>{
			todoList.value.push(item)
		})	
	}
})
```

####  方法1：子组件暴露todoList，让父组件响应式监听，然后传递给另一个子组件
在场景1中，我们已经将TodoList的todoList暴露
- TodoList.vue
```js
// 初始化为一个数组对象
// 注意:后续对这个数组的增删，todoList.value仍然是指向同一个数组
const todoList = ref([]) 

defineExpose({todoList})  // 将数据暴露出去
// 异步更新todoList数组内容
fetch(url).then(res.json()).then(data=> {
	if(data.success) {
		data.arr.forEach(item=>{
			todoList.value.push(item)
		})	
	}
})
```

- Page.vue
```js
onMounted(()=> {
	watch(todoListRef.value.todoList, ()=> {
		// 加了deep:true，todoList被增删改查都能检测到
	},{deep: true}) // 必须要加deep:true，否则无法检测对数组内容的修改
	// deep为false时，仅能监听todoList.value 被赋值的情况，也就是对象被修改
})
```

由于js对象引用给传递的特性，我们也可以在Page.vue中创建一个响应式对象监听子组件的todoList所监听的数组。也就是说，他们监听同一个数组对象。

- Page.vue
```js
const todoListRef = ref();
const todoList = ref(null);// 无所谓初始化，因为后面会将其关联到子组件的todoList监听的数组对象
onMounted(()=> {
	// 此时他们监听的就是同一个数组对象了，子组件做出的修改会在Page中也能响应
	todoList.value = todoListRef.value.todoList
})

...
<TodoList ref="todoListRef" />
<FileManager/>
```


#### 方法2：子组件不暴露todoList，而是通过emit方式通知父组件

- TodoList.vue
```js
const todoList = ref([])

const emit = defineEmits(['updateTodoList'])

// 异步更新todoList数组内容
fetch(url).then(res.json()).then(data=> {
	if(data.success) {
		data.arr.forEach(item=>{
			todoList.value.push(item)
		})	
	}
})
```

## 理解v-bind(简写:)与双向绑定v-model


### 场景1：Page.vue将自己动态属性传递给子组件

#### 方法1： 双向绑定：[v-model](https://cn.vuejs.org/guide/components/v-model.html)

- Page.vue
```js
const todoList = ref([])

// 方式1：v-model 双向绑定
<FileManager v-model="todoList" />   // 无参数传递v-model

// 带参数传递v-model,冒号后面的值可以自定义为任何名称
<FileManager v-model:myTodoList="todoList" />   
```

父组件传递过来的v-model，子组件可以在script中通过`defineModel`获取
- FileManager.vue
```js
// 无参数model
const todoList = defineModel({  
  default: []
})

//获取带参数的model，这里的第一个参数和v-model冒号后面的参数要相同
const todoList = defineModel('myTodoList', {  
  default: []  
})
```

需要注意的是，如果Page.vue中定义的todoList设置了默认值（null也是默认值），则defineModel的默认值会被覆盖。
- Page.vue
```js
const todoList = ref() // 没有设置默认值，则defineModel设置的默认值会生效
const todoList1 = ref(null) // null为默认值，defineModel设置的默认值会被null覆盖
const todoList2 = ref(['1', '2'])

<FileManager 
	v-model:todoList="todoList" 
	v-model:todoList1="todoList1" 
	v-model:todoList2="todoList2" 
/>  
```
- FileManager.vue

```js
//默认值生效
const todoList = defineModel('todoList', {default: ['hello']}) 
console.log(todoList.value) // ['hello']

//默认值被null覆盖，不生效
const todoList1 = defineModel('todoList1', {default: ['hello']}) 
console.log(todoList.value) // null

//默认值被['1','2']覆盖
const todoList1 = defineModel('todoList1', {default: ['hello']}) 
console.log(todoList.value) // ['1', '2']
```


#### 方法2：动态属性[v-bind](https://cn.vuejs.org/guide/components/props.html)

- Page.vue
```html
// v-bind缩写
<FileManager :todoList="todoList" />  
```
- FileManager.vue通过defineProps获取动态属性
```js
const props = defineProps({  
  todoList: {  
    type: Array,  
    default: []  
  }  
})

console.log(props.todoList) 
```

### 总结
无论是v-bind还是v-model，通过父模板传递给子模版的数据都应该是只读的，但是由于js对于对象引用传递的特性，你可以修改引用对象内部的内容，但是不推荐子模板直接修改，而是通过emit事件通知父组件修改他们传递过来的数据。简而言之：数据的修改应该由提供者实现。


### 场景2：如何正确初始化数据
现在FileManager有一个下拉列表，他的值由TodoList.vue组件中定义的todoList数组提供，要求FileManager默认选中第一个值。

- Page.vue
```js
const todoListRef=ref()
const todoList = ref();

onMounted(()=> {
	todoList.value = todoListRef.value.todoList
})

<TodoList ref="todoListRef" />
<FileManager v-model:todoList="todoList"  />
```

- TodoList.vue动态更新数据，给todo添加2个值
```js
const todoList = ref([])
// 假设从网络上请求了数据，并异步插入数据
setTimeout(()=> {
	todoList.value.push('hello')
	todoList.value.push('world')
}, 3000)
```

- FileManager.vue接受来自Page.vue的双向绑定数据
```js
// 注意这里Page.vue的ref()括号里面是空的，因此此处default生效
const todoList = defineModel('todoList', {defautl: ['1', '2']})
console.log(todoList.value) //  ['1', '2']
```
- FileManager.vue模板内容，此时未选择任何数据
```html
<select>   
  <option v-for="(todo, index) in todoList"  
		  :key="index"
		  :value="todo.name" >  
	{{ todo.name }}  
  </option>  
</select>
```


现在数据的来源和他们各自产生的变化已经捋清楚，已知TodoList.vue中会进行网络请求更新todoList的值，如何在完成请求后，让FileManager.vue获取到第一个值？


我们可以创建一个新的响应式对象todoSelect，用watch监听todoList的变化，当todoList.length>0的时候赋值，于是可能你会想到这样错误的写watch
- FileManager.vue
```js
const todoSelect = ref(null) // 用于存放当前下拉列表选择的值
const todoList = defineModel('todoList', {defautl: ['1', '2']})


watch(()=> todoList.value, (nv, ov)=> {  
// 非常遗憾，这无法监听todoList.value内部数据被修改的情况，而只能监听value换了另一个对象的变化情况。对于TodoList组件内部异步请求的更新不会改变对象本身，而是往数组里面push内容
  if(nv.length>0) { // 无效判断，nv甚至可能为空
    todoSelect.value = nv.value[0]
  }  
})
```

##### 提问1. 上面的`todoList.value`指向的对象地址什么时候发生变化？

要回答这个问题，首先要明确`todoList`的来源，显然来源于 `Page.vue` 定义的 `const todoList = ref()`，可以看到`Page.vue`中，在`onMounte`中修改了一次
```js
onMounted(()=> {  
  console.log('page mounted', todoList.value)  
  // 此处修改todoList.value，触发watch
  todoList.value = todoListRef.value.todoList   
  console.log('page todoList updated')

...
<TodoList />
<FileManager :todoList="todoList"/>
```

执行顺序如下：
1. TodoList组件被挂载，开始**异步**请求数据更新自己内部的todoList
2. FileManager组件被挂载，开启监听todoList
3. Page.vue最后挂载，**修改自己定义的todoList.value指向TodoList组件内部的数据**


> 最终答案就是，在Page.vue中的onMount里面修改时，发生变化。

##### 提问2：此时的`todoListRef.value.todoList` 是否有数据？

我们继续完善执行顺序，下面这种情况是无数据的情况：

1. TodoList组件被挂载，开始**异步**请求数据更新自己内部的todoList
2. FileManager组件被挂载，开启监听todoList
3. Page.vue最后挂载，**修改自己定义的todoList.value指向TodoList组件内部的数据**
4. 触发FileManager的watch(()=>todoList.value ...)，假设TodoList的异步请求尚未结束，因此在这里debug的数组没有任何值！但是仍然是同一个数组对象
5. TodoList组件网络请求成功，往todoList.value指向的数组开始添加数据，并不会修改todoList.value指向的对象（仍然是原来的数组）因此无法再次触发FileManager里面的watch


由于异步请求时间的不确定性，因此第五步并非固定的。我们把第五步位置换一下

1. TodoList组件被挂载，开始**异步**请求数据更新自己内部的todoList
2. TodoList组件网络请求成功，往todoList.value指向的数组开始添加数据
3. FileManager组件被挂载，开启监听todoList
4. Page.vue最后挂载，**修改自己定义的todoList.value指向TodoList组件内部的数据** ,注意到第2步中数据已经请求结束，此时获取到了数据
5. 触发FileManager的watch(()=>todoList.value ...)，由于TodoList的异步请求已经结束，其内部的todoList已经存放了新的内容，因此在这里debug的数组是有值的！


#### 验证todoList内部异步更新数据会影响watch()对数据的判断。

这里使用一个setTimeout延迟查看数据

- TodoList.vue
```js
const todoList = ref([])
setTimeout(()=> {
	todoList.value.push('a')
	todoList.value.push('b')
}, 2000)  // 模拟网络延迟2秒
```

- FileManaer.vue
```js
watch(()=> todoList.value, (nv, ov)=> {  
  console.log(todoList.value.length) // 0, 异步请求尚未结束
  setTimeout(()=> {  
    console.log(todoList.value.length) // 2 // 异步请求已经结束
  }, 5000)  // 假设5秒钟后异步请求结束  
})
```


### 结论：
- 不要错误的认为watch(()=> todoList.value) 会监听数组内部的修改。
- 考虑异步请求更新数据的时机

## 理解provide和inject（跨层传递）

## 理解v-on(缩写@)

