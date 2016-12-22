class ProgressBar
@@progress_status = "." * 100
@@progress_status_done = "|" * 100

	def initialize(overall_count, text) #integer, string
	  @overall_count = overall_count
	  @text = text
	end ; 

	def update_progress_bar(process)
	  phase = [1, (process * 100) / @overall_count].max #integer
	  Sketchup.set_status_text(@@progress_status_done[0, phase - 1] << @@progress_status[phase, @@progress_status.length] << "  " << (phase.to_s) << " %" << " #{@text}", SB_PROMPT)
	end ; 
end ;
