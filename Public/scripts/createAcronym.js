// 页面加载时，发送get请求
$.ajax({
    url: "/api/categories/",
    type: "GET",
    contentType: "application/json; charset=utf-8"
  }).then(function (response) {
    var dataToReturn = [];
    // 遍历所有返回分类并转换成JSON对象，添加到dataToReturn中
    for (var i=0; i < response.length; i++) {
        var tagToTransform = response[i];
        var newTag = {
                        id: tagToTransform["name"],
                        text: tagToTransform["name"]
                    };
    dataToReturn.push(newTag);
  }
  // 得到 categories id 的 html 元素，调用select2
  $("#categories").select2({
    // 4
    placeholder: "Select Categories for the Acronym",
    // 5
    tags: true,
    // 6
    tokenSeparators: [','],
    // 用户可以从存在分类中选择
    data: dataToReturn
  }); });