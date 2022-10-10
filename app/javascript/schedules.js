import Vue from 'vue/dist/vue.esm.js';

if(document.querySelector('#schedule-list')){
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
    }
  });
};