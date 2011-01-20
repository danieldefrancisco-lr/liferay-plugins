<%--
/**
 * Copyright (c) 2000-2011 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/admin/init.jsp" %>

<%
Template template = (Template)request.getAttribute(WebKeys.KNOWLEDGE_BASE_TEMPLATE);

Comment comment = null;

try {
	comment = CommentLocalServiceUtil.getComment(user.getUserId(), Template.class.getName(), template.getTemplateId());
}
catch (NoSuchCommentException nsce) {
}

long commentId = BeanParamUtil.getLong(comment, request, "commentId");

String content = BeanParamUtil.getString(comment, request, "content");
boolean helpful = BeanParamUtil.getBoolean(comment, request, "helpful", true);
%>

<c:if test="<%= layoutTypePortlet.hasPortletId(portletDisplay.getId()) && (enableTemplateComments || showTemplateComments) %>">
	<div class="kb-template-comments">
		<c:if test="<%= enableTemplateComments && themeDisplay.isSignedIn() %>">
			<liferay-ui:panel-container extended="<%= false %>" id='<%= renderResponse.getNamespace() + "Template" + template.getTemplateId() + "CommentsPanelContainer" %>' persistState="<%= true %>">
				<liferay-ui:panel collapsible="<%= true %>" defaultState="closed" extended="<%= true %>" id='<%= renderResponse.getNamespace() + "Template" + template.getTemplateId() + "CommentsPanel" %>' persistState="<%= true %>" title="comments">
					<c:if test="<%= comment != null %>">

						<%
						request.setAttribute("template_comments.jsp-comment", comment);
						%>

						<liferay-util:include page="/admin/template_comment.jsp" servletContext="<%= application %>" />
					</c:if>

					<aui:form method="post" name="fm" onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "updateComment();" %>'>
						<aui:input name="<%= Constants.CMD %>" type="hidden" />
						<aui:input name="commentId" type="hidden" value="<%= commentId %>" />
						<aui:input name="classNameId" type="hidden" value="<%= PortalUtil.getClassNameId(Template.class) %>" />
						<aui:input name="classPK" type="hidden" value="<%= template.getTemplateId() %>" />

						<liferay-ui:error exception="<%= CommentContentException.class %>" message="please-enter-valid-content" />

						<aui:input cssClass="lfr-textarea-container" label="" name="content" type="textarea" value="<%= content %>" />

						<div class="kb-helpful-inputs">
							<span class="kb-helpful-text"><liferay-ui:message key="was-this-information-helpful" /></span>

							<aui:input checked="<%= helpful %>" inlineField="<%= true %>" label="yes" name="helpful" type="radio" value="1" />
							<aui:input checked="<%= !helpful %>" inlineField="<%= true %>" label="no" name="helpful" type="radio" value="0" />
						</div>

						<aui:button-row cssClass="kb-submit-buttons">
							<aui:button type="submit" value="post" />
						</aui:button-row>
					</aui:form>
				</liferay-ui:panel>
			</liferay-ui:panel-container>
		</c:if>

		<c:if test="<%= showTemplateComments %>">
			<liferay-portlet:renderURL varImpl="iteratorURL">
				<portlet:param name="jspPage" value='<%= jspPath + "view_template.jsp" %>' />
				<portlet:param name="templateId" value="<%= String.valueOf(template.getTemplateId()) %>" />
			</liferay-portlet:renderURL>

			<liferay-ui:search-container
				iteratorURL="<%= iteratorURL %>"
			>
				<liferay-ui:search-container-results
					results="<%= CommentLocalServiceUtil.getComments(Template.class.getName(), template.getTemplateId(), searchContainer.getStart(), searchContainer.getEnd(), null) %>"
					total="<%= CommentLocalServiceUtil.getCommentsCount(Template.class.getName(), template.getTemplateId()) %>"
				/>

				<c:if test="<%= total > 0 %>">
					<div class="separator"><!-- --></div>
				</c:if>

				<%
				for (Comment curComment : (List<Comment>)results) {
				%>

					<%
					request.setAttribute("template_comments.jsp-comment", curComment);
					%>

					<liferay-util:include page="/admin/template_comment.jsp" servletContext="<%= application %>" />

				<%
				}
				%>

				<c:if test="<%= total > searchContainer.getDelta() %>">
					<div class="taglib-search-iterator-page-iterator-bottom">
						<liferay-ui:search-paginator searchContainer="<%= searchContainer %>" />
					</div>
				</c:if>
			</liferay-ui:search-container>
		</c:if>
	</div>

	<portlet:renderURL var="viewTemplateURL">
		<portlet:param name="jspPage" value='<%= jspPath + "view_template.jsp" %>' />
		<portlet:param name="templateId" value="<%= String.valueOf(template.getTemplateId()) %>" />
	</portlet:renderURL>

	<aui:script>
		function <portlet:namespace />deleteComment(commentId) {
			document.<portlet:namespace />fm.<portlet:namespace />commentId.value = commentId;
			submitForm(document.<portlet:namespace />fm, "<portlet:actionURL name="deleteComment"><portlet:param name="jspPage" value='<%= jspPath + "view_template.jsp" %>' /><portlet:param name="templateId" value="<%= String.valueOf(template.getTemplateId()) %>" /><portlet:param name="redirect" value="<%= viewTemplateURL %>" /></portlet:actionURL>");
		}

		function <portlet:namespace />updateComment() {
			document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "<%= (comment == null) ? Constants.ADD : Constants.UPDATE %>";
			submitForm(document.<portlet:namespace />fm, "<portlet:actionURL name="updateComment"><portlet:param name="jspPage" value='<%= jspPath + "view_template.jsp" %>' /><portlet:param name="templateId" value="<%= String.valueOf(template.getTemplateId()) %>" /><portlet:param name="redirect" value="<%= viewTemplateURL %>" /></portlet:actionURL>");
		}
	</aui:script>
</c:if>