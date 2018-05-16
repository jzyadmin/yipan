  <%@ page language="java" import="java.util.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/context/mytags.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>${ftl_description}</title>
<t:base type="jquery,easyui,tools,DatePicker,autocomplete"></t:base>
<link rel="stylesheet" href="plug-in/themes/naturebt/css/search-form.css">
</head>
<body>
<div class="easyui-layout" fit="true">
	<div region="center" style="padding:0px;border:0px">
		<table id="${entityName?uncap_first}List"></table>  
	</div>
	<div id = "${entityName?uncap_first}ListToolbar">
		<div class="easyui-panel toolbar-search" style="display:none">
			<form id="${entityName?uncap_first}Form" onkeydown="if(event.keyCode==13){doSearch();return false;}">
			<#list columns as po>
				<#if po.isQuery =='Y'>
				<div class="seerch-div">
					<label>${po.content}:</label>
					<div class="search-control">
					<#if po.showType?index_of("datetime")!=-1>
						<#if po.queryMode =='group'>
						<input type="text" name="${po.fieldName}_begin" class="dts search-inp Wdate search-group-inp"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" placeholder="请选择开始时间"/>
						<span class="dts search-group-span">~</span>
						<input type="text" name="${po.fieldName}_end" class="dts search-inp Wdate search-group-inp" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" placeholder="请选择结束时间"/>
						<#else>
						<input type="text" name="${po.fieldName}" class="dts search-inp Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" placeholder="请选择时间"/>
						</#if>
					<#elseif po.showType?index_of("date")!=-1>
						<#if po.queryMode =='group'>
						<input type="text" name="${po.fieldName}_begin" class="dts search-inp Wdate search-group-inp"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd'});" placeholder="请选择开始日期"/>
						<span class="dts search-group-span">~</span>
						<input type="text" name="${po.fieldName}_end" class="dts search-inp Wdate search-group-inp" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'});" placeholder="请选择结束日期"/>
						<#else>
						<input type="text" name="${po.fieldName}" class="dts search-inp Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'});" placeholder="请选择日期"/>
						</#if>
					<#elseif po.showType=='checkbox'|| po.showType=='radio'>
						<div class="${po.fieldName}-search search-div"></div>
					<#elseif  po.showType=='select' || po.showType=='list'>
						<select name = "${po.fieldName}" class="dts search-inp search-select"></select>
					<#else>
						<#if po.queryMode =='group'>
						<input type="text" name="${po.fieldName}_begin" class="dts search-inp" placeholder="请输入开始值"/>
						<span class="dts search-group-span">~</span>
						<input type="text" name="${po.fieldName}_end" class="dts search-inp" placeholder="请输入结束值"/>
						<#else>
						<input class="dts search-inp" type="text" name="${po.fieldName}" placeholder="请输入${po.content}"/>
						</#if>
					</#if>
					</div>
				</div>
				</#if>
			</#list> 
				<div class="seerch-div">
					<label style="visibility:hidden">查询</label>
					<div>
					<button type="button" class="tool-btn tool-btn-default tool-btn-xs" onclick="doSearch()">
						<i class="fa fa-search"></i>
						<span>查询</span>
					</button>
					
					<button type="button" class="tool-btn tool-btn-default tool-btn-xs" onclick="resetSearch()">
						<i class="fa fa-refresh"></i>
						<span>重置</span>
					</button>
					</div>
				</div>
			</form>
		</div>
		<div class="toolbar-btn">
			<button type="button" onclick="add('录入','${entityName?uncap_first}Controller.do?goAdd','${entityName?uncap_first}List','100%','100%')" class="tool-btn tool-btn-default tool-btn-xs">
				<i class="fa fa-plus"></i>
				<span>录入</span>
			</button>
			
			<button type="button" onclick="update('编辑','${entityName?uncap_first}Controller.do?goUpdate','${entityName?uncap_first}List','100%','100%')" class="tool-btn tool-btn-default tool-btn-xs">
				<i class="fa fa-edit"></i>
				<span>编辑</span>
			</button>
			
			<button type="button" onclick="deleteALLSelect('批量删除','${entityName?uncap_first}Controller.do?doBatchDel','${entityName?uncap_first}List',null,null)" class="tool-btn tool-btn-default tool-btn-xs">
				<i class="fa fa-trash"></i>
				<span>批量删除</span>
			</button>
		
			<button type="button" onclick="$('.toolbar-search').slideToggle();" class="tool-btn tool-btn-default tool-btn-xs">
				<i class="fa fa-arrow-circle-left"></i>
				<span>检索</span>
			</button>
		</div>
	</div>
</div>
<script>
var ${entityName?uncap_first}ListdictsData = {};
$(function(){
	var promiseArr = [];
	<#assign optionCodes="">
	<#list columns as po>
	<#if po.showType=='checkbox' || po.showType=='radio' || po.showType=='select' || po.showType=='list'>
	<#if optionCodes?index_of(po.dictField) lt 0>
	<#assign optionCodes=optionCodes+","+po.dictField >
	promiseArr.push(new Promise(function(resolve, reject) {
		initDictByCode(${entityName?uncap_first}ListdictsData,"${po.dictField}",resolve);
	}));
	</#if>
	</#if>
	</#list>
	
	Promise.all(promiseArr).then(function(results) {
		initDatagrid();
		$('#${entityName?uncap_first}List').datagrid('getPager').pagination({
	        beforePageText: '',
	        afterPageText: '/{pages}',
	        displayMsg: '{from}-{to}共 {total}条',
	        showPageList: true,
	        showRefresh: true
	    });
	    $('#${entityName?uncap_first}List').datagrid('getPager').pagination({
	        onBeforeRefresh: function(pageNumber, pageSize) {
	            $(this).pagination('loading');
	            $(this).pagination('loaded');
	        }
	    });
	    
		<#list columns as po>
		<#if po.isQuery =='Y'>
		<#if po.showType=='checkbox'||po.showType=='radio'>
		loadSearchFormDicts($("#${entityName?uncap_first}Form").find(".${po.fieldName}-search"),${entityName?uncap_first}ListdictsData.${po.dictField},"${po.showType}","${po.fieldName}");
		<#elseif  po.showType=='select' || po.showType=='list'>
		loadSearchFormDicts($("#${entityName?uncap_first}Form").find("select[name='${po.fieldName}']"),${entityName?uncap_first}ListdictsData.${po.dictField},"select");
		</#if>
		</#if>
		</#list>
	}).catch(function(err) {
		console.log('Catch: ', err);
	});
	
});

//easyui-datagrid实例化
function initDatagrid(){
	var actionUrl = "${entityName?uncap_first}Controller.do?datagrid&field=<#list columns as po>${po.fieldName},</#list>";
 	$('#${entityName?uncap_first}List').datagrid({
		url:actionUrl,
		idField: 'id', 
		title: '${ftl_description}',
		loadMsg: '数据加载中...',
		fit:true,
		fitColumns:false,
		striped:true,
		autoRowHeight: true,
		pageSize: 10,
		pagination:true,
		singleSelect:false,
		pageList:[10,30,50,100],
		rownumbers:true,
		showFooter:true,
		toolbar: '#${entityName?uncap_first}ListToolbar',
		frozenColumns:[[]],
		columns:[[
			{field:'ck',checkbox:true}
			<#list columns as po>
			,{
				field : "${po.fieldName}",
				title : "${po.content}",
				width : ${po.fieldLength},
				sortable: true,
				<#if po.isShowList?if_exists?html =='N'>
				hidden:true,
				</#if>
				<#if po.showType?index_of("datetime")!=-1>
				formatter : function(value, rec, index) {
					return new Date().format('yyyy-MM-dd hh:mm:ss', value);
				}
				<#elseif po.showType?index_of("date")!=-1>
				formatter : function(value, rec, index) {
					return new Date().format('yyyy-MM-dd', value);
				}
				<#elseif po.showType=='checkbox' || po.showType=='radio' || po.showType=='select' || po.showType=='list'>
				formatter : function(value, rec, index) {
					return listDictFormat(value,${entityName?uncap_first}ListdictsData.${po.dictField});
				}
				<#elseif po.showType=='image' ||po.showType=='file'>
				formatter:function(value,rec,index){
					return listFileImgFormat(value,"${po.showType}");
			 	}
				</#if>
			}
			</#list>
			,{
	            field: 'opt',title: '操作',width: 150,
	            formatter: function(value, rec, index) {
	                if (!rec.id) {
	                    return '';
	                }
	                var href = '';
	                href += "<a href='#'   class='ace_button'  onclick=delObj('${entityName?uncap_first}Controller.do?doDel&id=" + rec.id + "','${entityName?uncap_first}List')>  <i class=' fa fa-trash-o'></i> ";
	                href += "删除</a>&nbsp;";
	                return href;
	            }
	        }
		]],
		onLoadSuccess: function(data) {
            $("#${entityName?uncap_first}List").datagrid("clearSelections");
            if (!false) {
                if (data.total && data.rows.length == 0) {
                    var grid = $('#${entityName?uncap_first}List');
                    var curr = grid.datagrid('getPager').data("pagination").options.pageNumber;
                    grid.datagrid({
                        pageNumber: (curr - 1)
                    });
                }
            }
        }
	});
}

//easyui-datagrid重新加载
function reloadTable() {
	 $('#${entityName?uncap_first}List').datagrid('reload');
}

//easyui-datagrid搜索
function doSearch(){
	var queryParams = $('#${entityName?uncap_first}List').datagrid('options').queryParams;
	var actionUrl = "${entityName?uncap_first}Controller.do?datagrid&field=<#list columns as po>${po.fieldName},</#list>";
	$('#${entityName?uncap_first}Form').find(':input').each(function() {
		if("checkbox"== $(this).attr("type")){
			queryParams[$(this).attr('name')] = getCheckboxVal($(this).attr('name'));
		}else if("radio"== $(this).attr("type")){
			queryParams[$(this).attr('name')] = getRadioVal($(this).attr('name'));
		}else{
			queryParams[$(this).attr('name')] = $(this).val();
		}
    });
	
   $('#${entityName?uncap_first}List').datagrid({
        url: actionUrl,
        pageNumber: 1
    });
}

//easyui-datagrid重置搜索
function resetSearch(){
    var queryParams = $('#${entityName?uncap_first}List').datagrid('options').queryParams;
    $('#${entityName?uncap_first}Form').find(':input').each(function() {
    	if("checkbox"== $(this).attr("type")){
    		$("input:checkbox[name='" + $(this).attr('name') + "']").attr('checked',false);
		}else if("radio"== $(this).attr("type")){
			$("input:radio[name='" + $(this).attr('name') + "']").attr('checked',false);
		}else{
			$(this).val("");
		}
        queryParams[$(this).attr('name')] = "";
    });
    $('#${entityName?uncap_first}Form').find("input[type='checkbox']").each(function() {
        $(this).attr('checked', false);
    });
    $('#${entityName?uncap_first}Form').find("input[type='radio']").each(function() {
        $(this).attr('checked', false);
    });
    var actionUrl = "${entityName?uncap_first}Controller.do?datagrid&field=<#list columns as po>${po.fieldName},${po.fieldName}_begin,${po.fieldName}_end,</#list>";
    $('#${entityName?uncap_first}List').datagrid({
        url: actionUrl,
        pageNumber: 1
    });
}

//加载字典数据
function initDictByCode(dictObj,code,callback){
	if(!dictObj[code]){
		jQuery.ajax({
            url: "systemController.do?typeListJson&typeGroupName="+code,
    		type:"GET",
       		dataType:"JSON",
            success: function (back) {
               if(back.success){
            	   dictObj[code]= back.obj;
            	  
               }
               callback();
             }
         });
	}
}

//加载form查询数据字典项
function loadSearchFormDicts(obj,arr,type,name){
	var html = "";
	for(var a = 0;a < arr.length;a++){
		if("select"== type){
			html+="<option value = '"+arr[a].typecode+"'>"+arr[a].typename+"</option>";
		}else{
			if(!arr[a].typecode){
			}else{
				html+="<input name = '"+name+"' type='"+type+"' value = '"+arr[a].typecode+"'>"+arr[a].typename +"&nbsp;&nbsp;";
			}
			
		}
    }
	obj.html(html);
}
//获取Checkbox的值
function getCheckboxVal(name){
    var result = new Array();
    $("input[name='" + name + "']:checkbox").each(function() {
        if ($(this).is(":checked")) {
            result.push($(this).attr("value"));
        }
    });
    return result.join(",");
}
//获取radio的值
function getRadioVal(name){
	var v = $('input:radio[name="'+name+'"]:checked').val();
	if(!v){
		v ="";
	}
	return v;
}
//列表数据字典项格式化
function listDictFormat(value,dicts){
	if (!value) return '';
    var valArray = value.split(',');
    var showVal = '';
    if (valArray.length > 1) {
    	for (var k = 0; k < valArray.length; k++) {
           if(dicts && dicts.length>0){
        	   for(var a = 0;a < dicts.length;a++){
                	if(dicts[a].typecode ==valArray[k]){
                		showVal = showVal + dicts[a].typename + ',';
                		 break;
                	}
                }
           }
        }
        showVal=showVal.substring(0, showVal.length - 1);
    }else{
    	if(dicts && dicts.length>0){
    	   for(var a = 0;a < dicts.length;a++){
            	if(dicts[a].typecode == value){
            		showVal =  dicts[a].typename;
            		 break;
            	}
            }
       }
    }
    return showVal;
}

//列表文件图片 列格式化方法
function listFileImgFormat(value,type){
	var href='';
	if(value==null || value.length==0){
		return href;
	}
	if("image"==type){
 		href+="<img src='"+value+"' width=30 height=30  onmouseover='tipImg(this)' onmouseout='moveTipImg()' style='vertical-align:middle'/>";
	}else{
 		if(value.indexOf(".jpg")>-1 || value.indexOf(".gif")>-1 || value.indexOf(".png")>-1){
 			href+="<img src='"+value+"' onmouseover='tipImg(this)' onmouseout='moveTipImg()' width=30 height=30 />";
 		}else{
 			href+="<a href='"+value+"' class='ace_button' style='text-decoration:none;' target=_blank><u><i class='fa fa-download'></i>点击下载</u></a>";
 		}
	}
	return href;
}
</script>
</body>
</html>