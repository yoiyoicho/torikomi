import Vue from 'vue/dist/vue.esm.js';
import VCalendar from 'v-calendar';
Vue.use(VCalendar);

if(document.querySelector('#calendar')){
  new Vue({
    el: '#calendar',
    mounted() {
      const schedules_json = JSON.parse(this.$refs.schedules.dataset.schedules);
      this.schedules = schedules_json;
      this.setAttrs();
    },
    data: { 
      schedules: {},
      attrs: [],
    },
    methods: {
      setAttrs(){
        for (const schedule of this.schedules){
          const schedule_id = schedule['id'];
          const title = schedule['title'];
          const start_time_date = new Date(schedule['start_time']);
          this.attrs.push({
            key: `schedule-${schedule_id.toString()}`,
            bar: {
              color: schedule['status'] === 'to_be_sent' ? 'green' : 'gray'
            },
            dates: start_time_date,
            popover: {
              label: this.convertDateToString(start_time_date) + ' ' + title
            },
          });
        }
      },
      convertDateToString(date){
        hour_s = date.getHours().toString();
        minute_s = date.getMinutes().toString();
        if(minute_s.length == 1){
          minute_s = '0' + minute_s;
        }
        date_s = hour_s + ':' + minute_s
        return date_s;
      }
    }
  });
}
