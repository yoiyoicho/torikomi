import Vue from 'vue/dist/vue.esm.js';
import VCalendar from 'v-calendar';
Vue.use(VCalendar);

new Vue({
  el: '#app',
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
            label: start_time_date.getHours().toString() + ':' + start_time_date.getMinutes().toString() + ' ' + title
          },
        });
      }
    }
  }
});
