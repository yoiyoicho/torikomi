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
          //const body = schedule['body'];
          const start_time_date = new Date(schedule['start_time']);
          //const end_time = schedule['end_time'];
          //const status = schedule['status'];
          this.attrs.push({
            key: `schedule-${schedule_id.toString()}`,
            bar: {
              height: '3px',
              backgroundColor: 'red',
              borderColor: null,
              borderWidth: '1px',
              borderStyle:'solid',
              opacity: 1
            },
            highlight: {
              backgroundColor: '#ff8080',
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
