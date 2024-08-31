---
date: 2024-08-31T07:50:42+08:00
lastmod: 2024-08-31T08:51:25+08:00
categories:
  - 编程杂谈
  - 前端
  - Vuejs
title: Vuejs设置defineModel和ref默认值的注意事项
draft: "false"
tags:
  - Vuejs
series: 
---
## 场景： 顶层应用提供了一个数组，底层组件使用该数组并设置默认值

### 页面结构如下

Page.vue
	EditPanel.vue
		PointType.vue


-  Page.vue
```js
const pointTypes=["path", "target"];  
provide(injectKeyPointTypes, pointTypes); // 提供数据
```

- EditPanel.vue
```js
const pointType = ref(null) // 记录子组件选择了哪个数据

<PointType v-model:point-type="pointType" /> // 双向绑定
```

如果希望`PointType.vue`默认选中第一个pointType，并让`EditPanel.vue`得知，我们可以在`EditPanel.vue`中注入pointTypes，并让pointType.value赋值
```js
const pointTypes = inject(injectKeyPointTypes)  // 注入数组
const pointType = ref(pointTypes[0]) // 初始化

<PointType v-model:point-type="pointType" /> // 双向绑定
```

此时子组件如下：
- PointType.vue
```js
const pointTypes = inject(injectKeyPointTypes)  // 注入数组
const pointType = defineModel('pointType')
```
渲染出按钮组
```html
<div v-for="(pt, index) in pointTypes" :key="pt">  
  <input type="radio" :value="pt" :checked="pointType===pt"/>  
  <label for="typeTarget"> {{ pt }} </label>  
</div>
```

这种方式默认值的设置比较清晰，但是问题在于EditPanel.vue实际上并不需要注入这些数据。于是修改如下
- EditPanel.vue 删掉了inject
```js
// 由于删掉了数据的注入，在这里就没办法初始化为数组中的第一个数据了
const pointType = ref()

<PointType v-model:point-type="pointType" /> // 双向绑定
```

聪明的你查看 [defineModel](https://cn.vuejs.org/api/sfc-script-setup#definemodel)官方文档，兴奋的把default传入到defineModel的options中

- PointType.vue
```js
const pointTypes = inject(injectKeyPointTypes)  // 注入数组
const pointType = defineModel('pointType', {
	default: pointTypes[0] // 设置默认值
})
```

### defineModel设置默认值不允许引用变量
非常遗憾，报错了。defineModel的默认值不允许设置setup中的本地变量
```
`defineModel()` in <script setup> cannot reference locally declared variables because it will be hoisted outside of the setup() function. If your component options require initialization in the module scope, use a separate normal <script> to export the options instead.
```


于是分别尝试不同的写法
```js
const test = ['a', 'b']
const pointType = defineModel('pointType', {
	default: test[0] // 失败
})
```

尝试传入一个字符串，没问题。也就是说涉及到任何对象的访问都是失败的！除了常量
```js
const test = "hello"
const pointType = defineModel('pointType', {
	default: test // 成功
})
```


通过[查阅网络](https://stackoverflow.com/questions/69951687/vue-3-defineprops-are-referencing-locally-declared-variables)得知以下几种解决方案，就是不要在setup中定义 

- PointType.vue
```js
<script>  
export default {  
  setup() {  
    const pointTypes = ['a', 'b']  
    const pointType = defineModel('pointType',  
        {default: pointTypes[0]},  
    )  
    return { pointType, pointTypes }  
  },  
}  
</script>
```
发现模板根本访问不了pointType, pointTypes，debug也无法命中。



最终放弃了直接在defineModel中直接定义default，而是紧接着设置value，这符合逻辑，毕竟默认值就是在该子组件中设置的。到此问题解决
```js
const pointTypes = inject(injectKeyPointTypes)  
const pointType = defineModel('pointType')  
pointType.value = pointTypes[0]
```


### 父组件ref()细节
注意到官方的一句话 

> 如果为 `defineModel` prop 设置了一个 `default` 值且父组件没有为该 prop 提供任何值，会导致父组件与子组件之间不同步。在下面的示例中，父组件的 `myRef` 是 `undefined`, 而子组件的 `model` 是 1：

```js
// 子组件：
const model = defineModel({ default: 1 })

// 父组件
const myRef = ref()
<Child v-model="myRef"></Child>
```


通过验证发现的确如此。但是只要在子组件中手动赋值以下又同步了

```js
// 子组件：
const model = defineModel({ default: 1 })
model.value = 100 // 手动赋值一下

// 父组件
const myRef = ref()
<Child v-model="myRef"></Child>
```

于是对这句话的理解是，子组件设置的default属性值并不会被父组件检测到，假设后续没有对model做出任何修改，他们的数据就会一直不一致。
因此个人认为在父模板不做初始化的情况下，子组件做初始化应该用`手动赋值value`的方式设置一次，这样他们就保持一致了。