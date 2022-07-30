import Vue from 'vue/dist/vue.esm.js';

new Vue({
  el: '#schedule-list',
  data(){
    return{
      toBeSent: true,
      sent: false
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
    }
  },
  computed: {
    toBeSentStyle(){
      if(this.toBeSent == true){
        return ''
      }else{
        return 'display: none;'
      };
    },
    sentStyle(){
      if(this.sent == true){
        return ''
      }else{
        return 'display: none;'
      };
    }
  }
});