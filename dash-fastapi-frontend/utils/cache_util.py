from flask import session
from typing import Any, Dict
from config.env import CacheConfig
from collections import OrderedDict


class LRUCache:
    """Minimal LRU cache implementation replacing cachebox.LRUCache."""
    def __init__(self, maxsize: int = 128, iterable=None, capacity: int = 128):
        self._store: OrderedDict = OrderedDict()
        self._maxsize = maxsize
        self._capacity = capacity

    def get(self, key, default=None):
        if key not in self._store:
            return default
        self._store.move_to_end(key)
        return self._store[key]

    def insert(self, key, value):
        if key in self._store:
            self._store.move_to_end(key)
        self._store[key] = value
        while len(self._store) > self._maxsize:
            self._store.popitem(last=False)

    def __contains__(self, key):
        return key in self._store

    def __delitem__(self, key):
        del self._store[key]


class TTLCache:
    """Minimal TTL cache implementation replacing cachebox.TTLCache."""
    def __init__(self, maxsize: int = 0, ttl: int = 600):
        self._store: Dict[str, tuple] = {}
        self._maxsize = maxsize
        self._ttl = ttl

    def _is_expired(self, key):
        import time
        if key not in self._store:
            return True
        _, expiry = self._store[key]
        return time.time() > expiry

    def get(self, key, default=None):
        if self._is_expired(key):
            return default
        value, _ = self._store[key]
        return value

    def insert(self, key, value):
        import time
        self._store[key] = (value, time.time() + self._ttl)
        if self._maxsize > 0 and len(self._store) > self._maxsize:
            # Remove oldest
            oldest = next(iter(self._store))
            del self._store[oldest]

    def __contains__(self, key):
        return key in self._store and not self._is_expired(key)

    def __delitem__(self, key):
        del self._store[key]


cache_manager = LRUCache(
    maxsize=CacheConfig.lru_cache_maxsize,
    iterable=None,
    capacity=CacheConfig.lru_cache_capacity,
)
ttl_manager = TTLCache(
    maxsize=CacheConfig.ttl_cache_maxsize, ttl=CacheConfig.ttl_cache_expire
)


class CacheManager:
    @classmethod
    def get(cls, target_key: str):
        cache_value = (
            cache_manager.get(session.get('Authorization')).get(target_key)
            if cache_manager.get(session.get('Authorization'))
            else None
        )
        return cache_value

    @classmethod
    def set(cls, target_obj: Dict):
        cache = cache_manager.get(session.get('Authorization'))
        if cache:
            cache.update(target_obj)
        else:
            cache = target_obj
        cache_manager.insert(session.get('Authorization'), cache)

    @classmethod
    def delete(cls, target_key: str):
        cache = cache_manager.get(session.get('Authorization'))
        cache.pop(target_key, None)
        cache_manager.insert(session.get('Authorization'), cache)

    @classmethod
    def clear(cls):
        cache = cache_manager.get(session.get('Authorization'))
        if cache:
            del cache_manager[session.get('Authorization')]


class TTLCacheManager:
    @classmethod
    def get(cls, target_key: str):
        return ttl_manager.get(target_key)

    @classmethod
    def set(cls, target_key: str, target_value: Any):
        ttl_manager.insert(target_key, target_value)

    @classmethod
    def delete(cls, target_keys: str):
        target_key_list = target_keys.split(',')
        for target_key in target_key_list:
            if ttl_manager.get(target_key) is not None:
                del ttl_manager[target_key]
