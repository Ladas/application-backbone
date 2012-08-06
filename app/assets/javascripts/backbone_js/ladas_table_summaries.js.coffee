class TableSummaries
  @refresh:(obj) ->
    if obj.summaries?
      for summary in obj.summaries
        do (summary) ->
          if (summary.summary_content_id? && summary.value?)
            $("#" + summary.summary_content_id).html(summary.value)
            if summary.class?
              $("#" + summary.summary_content_id).removeClass();
              $("#" + summary.summary_content_id).addClass(summary.class)

    return




window.TableSummaries = TableSummaries





