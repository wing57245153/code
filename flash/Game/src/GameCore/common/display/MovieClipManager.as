package GameCore.common.display
{
	import GameCore.util.TimerManager;

    public class MovieClipManager
    {
        private static var _instance:MovieClipManager;

        private var _mcVec:Vector.<BitmapMovieClip>;

        public function MovieClipManager()
        {
            _mcVec = new Vector.<BitmapMovieClip>();
            TimerManager.getInstance().add(33, updateDisplay);
        }

        public static function getInstance() : MovieClipManager
        {
            if(!_instance)
                _instance = new MovieClipManager();
            return _instance;
        }

        public function add(mc:BitmapMovieClip) : void
        {
            if(_mcVec.indexOf(mc) < 0)
                _mcVec.push(mc);
        }

        public function remove(mc:BitmapMovieClip) : void
        {
            var index:int = _mcVec.indexOf(mc);
            if(index > -1)
                _mcVec.splice(index, 1);
        }

        private function updateDisplay() : void
        {
            for each(var mc:BitmapMovieClip in _mcVec)
            {
                mc.step();
            }
        }
    }
}
