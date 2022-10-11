import Vue from 'vue/dist/vue.esm.js';

if(document.querySelector('#schedule-list')){
  new Vue({
    el: '#schedule-list',
    mounted() {
      const schedules_json = JSON.parse(this.$refs.schedules.dataset.schedules);
      this.setAccordionFlags(schedules_json);
    },
    data(){
      return{
        toBeSent: true,
        sent: false,
        accordionFlags: {},
        flag: false
      };
    },
    methods:{
      toBeSentTabClick(){
        this.toBeSent = true;
        this.sent = false;
      },
      sentTabClick(){
        this.toBeSent = false;
        this.sent = true;
      },
      setAccordionFlags(schedules_json){
        for(const schedule_json of schedules_json){
          this.accordionFlags[schedule_json.id.toString()] = false;
        }
      },
      clickAccordion(schedule_id){
        this.$set(this.accordionFlags, schedule_id, !this.accordionFlags[schedule_id]);
        this.flag = !this.flag;
      }
    }
  });
};